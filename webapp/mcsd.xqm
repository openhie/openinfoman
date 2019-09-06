module namespace page = 'http://basex.org/modules/web-page';
import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
import module namespace functx = 'http://www.functx.com';
import module namespace csr_proc = "https://github.com/openhie/openinfoman/csr_proc";
import module namespace csd_webui =  "https://github.com/openhie/openinfoman/csd_webui";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace svs_lsvs = "https://github.com/openhie/openinfoman/svs_lsvs";
declare namespace csd =  "urn:ihe:iti:csd:2013";
declare namespace svs = "urn:ihe:iti:svs:2008";
declare namespace UUID = "java.util.UUID";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $page:namespace_uuid := "10df44d2-55f4-11e4-af21-705681a860b7";

declare function page:uuid_tobits($tokens) {
  if (count($tokens) > 1)
  then  (
          bin:hex(concat($tokens[1],$tokens[2])),
          page:uuid_tobits(subsequence($tokens,3))
        )
  else $tokens
};

declare function page:getDayOfTheWeek ($day) {
  if($day = 1) then "mon"
  else if ($day = 2) then "tue"
  else if ($day = 3) then "wed"
  else if ($day = 4) then "thu"
  else if ($day = 5) then "fri"
  else if ($day = 6) then "sat"
  else if ($day = 7) then "sun"
  else ()
};

declare function page:uuid_generate($name,$namespace) {
  let $ns_bits := page:uuid_tobits(functx:chars(translate($namespace,'-','' )))
  let $n_bytes := convert:string-to-base64($name)
  let $uuid := UUID:nameUUIDFromBytes(  bin:join(($ns_bits, $n_bytes)))
  return lower-case($uuid)
};

declare function page:get_location ($doc_name,$_id,$page,$_count,$_since)
{
  <CSD xmlns:csd="urn:ihe:iti:csd:2013">
    {
      let $search_collection :=
      <collection>
        <search directory="facilityDirectory">urn:ihe:iti:csd:2014:stored-function:facility-search</search>
        <search directory="organizationDirectory">urn:ihe:iti:csd:2014:stored-function:organization-search</search>
      </collection>
      for $search in $search_collection/search
      let $search_name := $search/text()
      return
      (
        let $careServicesSubRequest :=
        <csd:careServicesRequest>
          <csd:function urn="{$search_name}" resource="{$doc_name}" base_url="{csd_webui:generateURL('')}">
            <csd:requestParams>
              {
                let $id := $_id
                return if (functx:all-whitespace($id)) then () else <csd:id entityID="{$id}"/>
              }

              {
                let $t_start := $page
                return if (functx:is-a-number($t_start))
                  then
                    let $start := max((xs:int($t_start),1))
                    let $t_count := $_count
                    let $count := if(functx:is-a-number($t_count)) then  max((xs:int($t_count),1)) else 50
                    let $startIndex := ($start - 1)*$count + 1
                    return <csd:start>{$startIndex}</csd:start>
                  else ()
              }
         {
           let $count := $_count
           return
              if(functx:is-a-number($count))
              then  <csd:max>{max((xs:int($count),1))} </csd:max>
              else ()
         }
         {
          let $since := $_since
          return if (functx:all-whitespace($since)) then () else <csd:record updated="{$since}"/>
         }
            </csd:requestParams>
          </csd:function>
        </csd:careServicesRequest>

        let $doc :=  csd_dm:open_document($doc_name)
        let $contents := csr_proc:process_CSR_stored_results( $doc , $careServicesSubRequest)
        let $directory := $search/@directory/string()
        return $contents/*[name() = $directory]
      )
    }
  </CSD>
};

declare
  %rest:path("/mcsd")
  %rest:GET
  function page:FHIR()
{
  let $output :=
                <json type='object'>
                  <issue type="array">
                    <_ type="object">
                      <code>processing</code>
                      <diagnostics>This is the base URL of FHIR server. Unable to handle this request, as it does not contain a resource type or operation name. to get Locations use http://localhost:8984/doc_name/mcsd/Location</diagnostics>
                      <details type="object">
                        <text>Internal server error</text>
                      </details>
                      <severity>error</severity>
                    </_>
                  </issue>
                  <resourceType>OperationOutcome</resourceType>
                </json>
    return (
              <rest:response>
                <output:serialization-parameters>
                  <output:media-type value='application/json'/>
                </output:serialization-parameters>
              </rest:response>,
              json:serialize($output,map{"format":"direct",'escape': 'no'})
            )
};

declare
  %rest:path("/{$doc_name}/mcsd/Location")
  %rest:query-param("_id", "{$_id}")
  %rest:query-param("page", "{$page}")
  %rest:query-param("_count", "{$_count}")
  %rest:query-param("_since", "{$_since}")
  %rest:GET
  function page:FHIRLocation($_id,$page,$_count,$_since,$doc_name)
{
let $contents := page:get_location ($doc_name,$_id,$page,$_count,$_since)
let $location :=
<json type='object'>
<resourceType>Bundle</resourceType>
<total>{count($contents/facilityDirectory/facility) + count($contents/organizationDirectory/organization)}</total>
<type>batch</type>
<meta type="object">
  <lastUpdated>{current-dateTime()}</lastUpdated>
</meta>
<timestamp>{current-dateTime()}</timestamp>
<id>{concat('urn:uuid:', random:uuid())}</id>
<entry type="array">
{
for $content in ($contents/facilityDirectory/facility,$contents/organizationDirectory/organization)
let $entityType := $content/name()
let $orgUUID := concat('urn:uuid:', page:uuid_generate($content/@entityID, $page:namespace_uuid))
let $organizationResource :=
  if($entityType = "csd:facility" or $entityType = "facility") then
    (
      <_ type="object">
      <fullURL>{csd_webui:generateURL($doc_name || "/mcsd/Organization/" || $orgUUID)}</fullURL>
      <request type="object">
        <method>PUT</method>
        <url>Organization/{$orgUUID}</url>
      </request>
      <resource type="object">
        <resourceType>Organization</resourceType>
        <meta type="object">
          <profile>mCSDFacility</profile>
        </meta>
        <name>{$content/primaryName/text()}</name>
        <id>{$orgUUID}</id>
        <type type="array">
          <_ type="object">
            <coding type="array">
              <_ type="object">
                <system>urn:ietf:rfc:3986</system>
                <code>urn:ihe:iti:mcsd:2019:facility</code>
                <display>Facility</display>
                <userSelected>false</userSelected>
              </_>
            </coding>
          </_>
        </type>
      </resource>
      </_>
    )
  else ()
  let $locationResource :=
<_ type="object">
  <fullURL>{csd_webui:generateURL($doc_name || "/mcsd/Location/" || $content/@entityID)}</fullURL>
  <request type="object">
    <method>PUT</method>
    <url>Location/{$content/@entityID/string()}</url>
  </request>
  <resource type="object">
    <resourceType>Location</resourceType>
      <meta type="object">
        <lastUpdated>{$content/record/@updated/string()}</lastUpdated>
        {
          if($entityType = "csd:facility" or $entityType = "facility") then
          (<profile>mCSDFacility</profile>)
          else if($entityType = "csd:organization" or $entityType = "organization") then
          (<profile>mCSD</profile>)
          else()
        }
        <tag type="array">
        <_ type="object">
            <code>{$content/record/@sourceDirectory/string()}</code>
            <system>https://github.com/openhie/openinfoman/tags/fhir/sourceDirectory</system>
          </_>
        </tag>
      </meta>
    <id>{$content/@entityID/string()}</id>
    {
     if(exists($content/otherID))
     then
     <identifier type="array">
      {
      for $otherid in $content/otherID
      return
      <_ type="object">
        <value>{$otherid/text()}</value>
        {
          if($otherid/@code/string()) then
          (
            <type type="object">
              <text>{$otherid/@code/string()}</text>
            </type>
          )
          else ()
        }
        <assigner type="object">
          <display>{$otherid/@assigningAuthorityName/string()}</display>
        </assigner>
      </_>
      }
      <_ type="object">
        <system>urn:ihe:iti:csd:2013:entityID</system>
        <value>{$content/@entityID/string()}</value>
        <type type="object">
          <text>entityID</text>
        </type>
      </_>
     </identifier>
     else ()
    }
    {
      let $search_name := "urn:ihe:iti:csd:2014:stored-function:organization-search"
      let $parent :=
      if(exists($content/organizations/organization))
      then
      $content/organizations/organization/@entityID/string()
      else
      if (exists($content/parent))
      then $content/parent/@entityID/string()
      else ()

      return if($parent)
      then
      let $careServicesSubRequest :=
      <csd:careServicesRequest>
        <csd:function urn="{$search_name}" resource="{$doc_name}" base_url="{csd_webui:generateURL()}">
          <csd:requestParams>
            <csd:id entityID="{$parent}"/>
          </csd:requestParams>
        </csd:function>
      </csd:careServicesRequest>
      let $doc :=  csd_dm:open_document($doc_name)
      let $organization := csr_proc:process_CSR_stored_results( $doc , $careServicesSubRequest)
      return if(exists($organization/organizationDirectory/organization))
      then
      <partOf type="object">
        <reference>{csd_webui:generateURL($doc_name || "/mcsd/Location/" || $organization/organizationDirectory/organization/@entityID/string())}</reference>
        <display>{$organization/organizationDirectory/organization/primaryName/text()}</display>
      </partOf>
      else ()
      else ()
    }
    <physicalType type="object">
      <coding type="array">
        <_ type="object">
          <system>http://hl7.org/fhir/location-physical-type</system>
          {
            if($entityType = "csd:facility" or $entityType = "facility") then
            ( <code>bu</code>,
              <display>Building</display>
            )
            else if($entityType = "csd:organization" or $entityType = "organization") then
            (
              <code>jdn</code>,
              <display>Jurisdiction</display>
            )
            else ()
          }
        </_>
      </coding>
      {
        if($entityType = "csd:facility" or $entityType = "facility") then
          <text>Building</text>
        else if($entityType = "csd:organization" or $entityType = "organization") then
          <text>Jurisdiction</text>
        else ()
      }
    </physicalType>
    {
      if($entityType = "csd:facility" or $entityType = "facility") then
        <managingOrganization type="object">
          <reference>Organization/{$orgUUID}</reference>
        </managingOrganization>
      else ()
    }
    {
    if(exists($content/contactPoint))
    then
    <telecom type="array">
     {
      for $contactPoint in $content/contactPoint
      return
        <_ type="object">
        {
          <system>
            {
              let $code := $contactPoint/codedType/@code/string()
              return if($code = "BP") then "phone"
                else if ($code = "EMAIL") then "email"
                else if ($code = "FAX") then "fax"
                else "other"
            }
          </system>
        }
          <value>{$contactPoint/codedType/text()}</value>
        </_>
     }
    </telecom>
    else ()
    }
    {
    if(exists($content/address/addressLine))
        then
        <address type="array">
          {
            for $address in $content/address
            return
              if(exists($address/addressLine))
              then
              <_ type="object">
                {
                  let $csdtype := lower-case($address/@type/string())
                  let $fhirtype := if($csdtype = "mailing" or $csdtype = "mailing address") then "postal"
                                    else if ($csdtype = "physical" or $csdtype = "physical address") then "physical"
                                    else ()
                  return if($fhirtype)
                          then <type>{$fhirtype}</type>
                          else ()
                }
                {
                  for $addressLine in $address/addressLine
                  return if($addressLine/@component = "streetAddress")
                    then <line>{$addressLine/text()}</line>
                    else if($addressLine/@component = "city")
                    then <city>{$addressLine/text()}</city>
                    else if($addressLine/@component = "district")
                    then <district>{$addressLine/text()}</district>
                    else if($addressLine/@component = "stateProvince")
                    then <state>{$addressLine/text()}</state>
                    else if($addressLine/@component = "country")
                    then <country>{$addressLine/text()}</country>
                    else if($addressLine/@component = "postalCode")
                    then <postalCode>{$addressLine/text()}</postalCode>
                    else()
                }
              </_>
              else ()
          }
        </address>
        else ()
    }
    {
      if(exists($content/geocode))
      then
      <position type="object">
        <longitude>{$content/geocode/longitude/text()}</longitude>
        <latitude>{$content/geocode/latitude/text()}</latitude>
        {
          if($content/geocode/altitude/text()) then
            <altitude>{$content/geocode/altitude/text()}</altitude>
          else ()
        }
      </position>
      else ()
    }
    <type type="array">
      {
        if($entityType = "csd:facility" or $entityType = "facility") then
          <_ type="object">
            <coding type="array">
              <_ type="object">
                <system>urn:ietf:rfc:3986</system>
                <code>urn:ihe:iti:mcsd:2019:facility</code>
                <display>Facility</display>
                <userSelected>false</userSelected>
              </_>
            </coding>
          </_>
        else ()
      }
      {
        for $codedType in $content/codedType
          return
            <_ type="object">
              <coding type="array">
                <_ type="object">
                  <code>{$codedType/@code/string()}</code>
                  <system>{$codedType/@codingScheme/string()}</system>
                  {
                  if(functx:all-whitespace($codedType/text()))
                  then ()
                  else
                  <display>{$codedType/text()}</display>
                  }
                </_>
              </coding>
              <text>{$codedType/text()}</text>
            </_>
      }
    </type>
    <status>{$content/record/@status/string()}</status>
    <name>{$content/primaryName/text()}</name>
    {
      if($content/otherName) then
        <alias type="array">
        {
          for $otherName in $content/otherName
            return
              <_>{$otherName/string()}</_>
        }
        </alias>
      else ()
    }
    {
      if(exists($content/operatingHours))then
      <hoursOfOperation type="array">
      {
        for $operatingHours in $content/operatingHours
          return
          <_ type="object">
          {
            let $CSDdayOfTheWeek := $operatingHours/dayOfTheWeek/text()
              let $FHIRdayOfTheWeek := page:getDayOfTheWeek($CSDdayOfTheWeek)
              return (
                <daysOfWeek>{$FHIRdayOfTheWeek}</daysOfWeek>,
                <openingTime>{$operatingHours/beginningHour/text()}</openingTime>,
                <closingTime>{$operatingHours/endingHour/text()}</closingTime>
              )
          }
          </_>
      }
      </hoursOfOperation>
      else ()
    }
  </resource>
</_>
  return($organizationResource,$locationResource)
}
</entry>
</json>
return (
  <rest:response>
    <output:serialization-parameters>
      <output:media-type value='application/json'/>
    </output:serialization-parameters>
  </rest:response>,
  json:serialize($location,map{"format":"direct",'escape': 'no'})
  )

};
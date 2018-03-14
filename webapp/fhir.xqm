module namespace page = 'http://basex.org/modules/web-page';
import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
import module namespace functx = 'http://www.functx.com';
import module namespace csr_proc = "https://github.com/openhie/openinfoman/csr_proc";
import module namespace csd_webui =  "https://github.com/openhie/openinfoman/csd_webui";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
declare namespace fhir = "http://hl7.org/fhir";
declare namespace csd =  "urn:ihe:iti:csd:2013";
declare default element  namespace   "urn:ihe:iti:csd:2013";


declare function page:get_location ($doc_name,$_id,$page,$_count,$_since)
{
  <CSD xmlns:csd="urn:ihe:iti:csd:2013"  >
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
  %rest:path("/FHIR/Location/_history/{$id}")
  %rest:query-param("page", "{$page}")
  %rest:query-param("_count", "{$_count}")
  %rest:query-param("_since", "{$_since}")
  %rest:query-param("doc_name", "{$doc_name}")
  %rest:GET
  function page:FHIRID($id,$page,$_count,$_since,$doc_name)
{
  page:FHIR($id,$page,$_count,$_since,$doc_name)
};

declare
  %rest:path("/FHIR/Location/_history")
  %rest:query-param("_id", "{$_id}")
  %rest:query-param("page", "{$page}")
  %rest:query-param("_count", "{$_count}")
  %rest:query-param("_since", "{$_since}")
  %rest:query-param("doc_name", "{$doc_name}")
  %rest:GET
  function page:FHIR($_id,$page,$_count,$_since,$doc_name)
{
let $contents := page:get_location ($doc_name,$_id,$page,$_count,$_since)
 
let $location :=
<json type='object'>
<resourceType>Bundle</resourceType>
<total>{count($contents/facilityDirectory/facility) + count($contents/organizationDirectory/organization)}</total>
<type>history</type>
<entry type="array">
{
for $content in ($contents/facilityDirectory/facility,$contents/organizationDirectory/organization)
return
<_ type="object">
{
  <fullURL>{csd_webui:generateURL('FHIR/Location/_history/' || $content/@entityID)}?doc_name={$doc_name}</fullURL>,
  <resource type="object">
    <resourceType>Location</resourceType>
    <id>{$content/@entityID/string()}</id>
    {
     if(exists($content/otherID))
     then
     <identifier type="array">
      {
      for $otherid in $content/otherID
      return
      <_ type="object">
        <system>{$otherid/@assigningAuthorityName/string()}/{$otherid/@code/string()}</system>
        <value>{$otherid/text()}</value>
      </_>
      }
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
        <reference>{csd_webui:generateURL('FHIR/Location/_history/' || $organization/organizationDirectory/organization/@entityID/string())}?doc_name={$doc_name}</reference>
        <display>{$organization/organizationDirectory/organization/primaryName/text()}</display>
      </partOf>
      else ()
      else ()
    }
    {
    if(exists($content/contactPoint))
    then
    <telecom type="array">
     {
     for $contactPoint in $content/contactPoint
     return ()
     }
    </telecom>
    else ()
    }
    {
      if(exists($content/geocode))
      then 
      <position type="object">
        <longitude>{$content/geocode/longitude/text()}</longitude>
        <latitude>{$content/geocode/latitude/text()}</latitude>
      </position>
      else ()
    }
    <meta type="object">
     <lastUpdated>{$content/record/@updated/string()}</lastUpdated>
    <tag type="array">
      <_ type="object">
        <code>{$content/record/@sourceDirectory/string()}</code>
        <system>https://github.com/openhie/openinfoman/tags/fhir/sourceDirectory</system>
      </_>
    </tag>
    </meta>
    {
      if(exists($content/codedType))
      then
        <type type="object">
          <coding type="array">
            {
              for $codedType in $content/codedType
                return
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
            }
          </coding>
        </type>
      else ()
    }
  </resource>,
  <status>{$content/record/@status/string()}</status>,
  <name>{$content/primaryName/text()}</name>,
  <mode>instance</mode>
}
</_>
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

declare
  %rest:path("/test")
  %rest:query-param("_id", "{$_id}")
  %rest:query-param("page", "{$page}")
  %rest:query-param("_count", "{$_count}")
  %rest:query-param("_since", "{$_since}")
  %rest:query-param("doc_name", "{$doc_name}")
  %rest:GET
  function page:test($_id,$page,$_count,$_since,$doc_name)
{
let $contents := page:get_location ($doc_name,$_id,$page,$_count,$_since)
return $contents/organizationDirectory/organization
};
(:~
: This is the Care Services Discovery base XQuery module
: @version 1.0
: @see http://ihe.net
:
:)
module namespace csd = "https://github.com/openhie/openinfoman/csd_bl";
declare default element  namespace   "urn:ihe:iti:csd:2013";



import module namespace random = "http://basex.org/modules/random";


(:Utility methods:)
declare function csd:wrap_providers($providers) 
{
<CSD xmlns:csd="urn:ihe:iti:csd:2013"  >
  <organizationDirectory/>
  <serviceDirectory/>
  <facilityDirectory/>
  <providerDirectory>
  {$providers}
  </providerDirectory>
</CSD>

};


declare function csd:wrap_organizations($organizations) 
{
<CSD xmlns:csd="urn:ihe:iti:csd:2013"  >
  <organizationDirectory>
  {$organizations}
  </organizationDirectory>
  <serviceDirectory/>
  <facilityDirectory/>
  <providerDirectory/>
</CSD>

};

declare function csd:wrap_facilities($facilities) 
{
<CSD xmlns:csd="urn:ihe:iti:csd:2013"  >
  <organizationDirectory/>
  <serviceDirectory/>
  <facilityDirectory>
  {$facilities}
  </facilityDirectory>
  <providerDirectory/>
</CSD>

};


declare function csd:wrap_services($services) 
{
<CSD xmlns:csd="urn:ihe:iti:csd:2013"  >
  <organizationDirectory/>
  <serviceDirectory>
    {$services}
  </serviceDirectory>
  <facilityDirectory/>
  <providerDirectory/>
</CSD>

};


(:~
 :Generate UUID as OID according to http://www.itu.int/ITU-T/asn1/uuid.html
 :)
declare function csd:uuid_as_oid() {
  let $zero := convert:binary-to-bytes('0')
  let $nine := convert:binary-to-bytes('9')
  let $a := convert:binary-to-bytes('A')
  let $e := convert:binary-to-bytes('E')
  let $uuid := convert:binary-to-bytes(upper-case(translate(random:uuid(),'-','')))
  let $uuid_dec := $uuid
    ! xs:decimal(if ( (. >= $zero and . <= $nine)) then (.  - $zero) else if ( (. >= $a and . <= $e)) then (. - $a + 10) else ())
  return concat('2.25.',   fold-left($uuid_dec, 0, function($a, $b) { $a * 16 + $b }) )
};

(:~
 : this function accepts a list of items to filter by address 
 :
 : @param $items - a list of items to filter by their <address/> child elements
 : @param $components - a list of address component values.  Each item should have an @component attribute indicating the component type. The text content is the component value.
 : @return all items in $items which have address/addressLine which matches exactly (case insensitive) on each of the given components.
 : @since 1.0
 : 
:)
declare function csd:filter_by_address($items as item()*,$components as item()*) as item()* 
{
    if (count($components) = 0 
       or not ($components[1]/@component)
       or not ($components[1]/text())
    ) 
    then  $items
    else  
           let $comp := $components[1]/@component
           let $val := fn:upper-case($components[1]/text())	     
           return csd:filter_by_address(
	     $items[address/addressLine[@component = $comp and fn:upper-case(text()) = $val]],
	     fn:subsequence($components,2))
};


(:~
 : this function accepts a list of items to filter by address 
 :
 : @param $items - a list of items to filter by their <address/> child elements
 : @param $components - a list of address component values.  Each item should have an @component attribute indicating the component type. The text content is the component value.
 : @return all items in $items which have address/addressLine which matches exactly (case insensitive) on each of the given components.
 : @since 1.0
 : 
:)
declare function csd:filter_by_demographic_address($items as item()*,$components as item()*) as item()* 
{
    if (count($components) = 0 
       or not ($components[1]/@component)
       or not ($components[1]/text())
    ) 
    then  $items
    else  
           let $comp := $components[1]/@component
           let $val := fn:upper-case($components[1]/text())	     
           return csd:filter_by_address(
	     $items[demographic/address/addressLine[@component = $comp and fn:upper-case(text()) = $val]],
	     fn:subsequence($components,2))
};

(:~
 : this function accepts a list of items to filter by type
 :
 : @param $items - a list of items to filter by their <codedType/> child elements
 : @param $codedtype - a coded type, if specified, to filter the $items list by type.  A @code attribute, if present, results in selecting those $items with matching codedType/@code (case-insensitive) exactly.  Text content, if present,  results in selecting the $items whose codedType/text() contains that value (case-insensitive) with the given @codingScheme (case-insensitive)
 : @return all items in $items which match as above
 : @since 1.0
 : 
:)
declare function csd:filter_by_coded_type($items as item()*, $codedtype as item()) as item()*
{
     if (exists($codedtype/@code) and exists($codedtype/@codingScheme))
     then
        let $code := fn:upper-case($codedtype/@code)
	    let $cScheme := $codedtype/@codingScheme
        return $items[codedType[
                @code = $code
 	            and
                @codingScheme = $cScheme
                ]
            ]
     else $items
};



(:~
 : this function accepts a list of items to filter by their primary name
 :
 : @param $items - a list of items to filter by their <primaryName/> child elements
 : @param $primaryName - a name, if specified, to filter the $items list by their <primaryName/> child elements.  The text content of $primaryName, if present, results in selecting those $items containing that content. Case-insenisitive.
 : @return all items in $items which match as above
 : @since 1.0
 : 
:)
declare function csd:filter_by_primary_name($items as item()*,$primaryName as item()) as item()* 
{

      if (not($primaryName = '')) 
      then 
          let $u_primaryName := fn:upper-case($primaryName)
          return $items[contains(fn:upper-case(./primaryName) , $u_primaryName)]
      else $items          
};


(:~
 : this function accepts a list of items to filter by their primary name or other name
 :
 : @param $items - a list of items to filter by their <primaryName/> and <otherName/> child elements
 : @param $name - a name, if specified, to filter the $items list by either their <primaryName/> or <otherName/> child elements .  The text content of $name, if present, results in selecting those $items containing that content. Case-insenisitive.
 : @return all items in $items which match as above
 : @since 1.0
 : 
:)
declare function csd:filter_by_name($items as item()*,$name as item()) as item()* 
{
  if (not($name = '')) 
    then  
    let $u_name:= fn:upper-case($name)
    for $item in $items
      let $matches0:= 
        for $name in $item/otherName
	return if (contains(upper-case($name),$u_name)) then ($name) else ()
      let $matches1 := ($matches0, $item[contains(upper-case(primaryName),$u_name)])
      where  count($matches1) > 0
     return $item
  else $items            
};  


(:~
 : this function accepts a list of items to filter by their primary id
 :
 : @param $items - a list of items to filter by their primary id
 : @param $id - a uniqueID, if present with an non-empty @urn attribute then it is used to filter the $items list by their @entryID attributes by performing an exact match of the @entryID $id.
 : @return all items in $items which match as above
 : @since 1.0
 : 
:)
declare function csd:filter_by_primary_id($items as item()*,$id as item()) as item()* 
{
       if ($id/@entryID) 
       then $items[@entryID =$id/@entryID]
       else $items
};


(:~
 : this function accepts a list of items to filter by their  by their <otherId/> child elements
 :
 : @param $items - a list of items to filter by their id
 : @param $id - an otherIDI, if specified, to filter the $items list by their @code and @assigningAuthorityName attributes any child <otherID> elements by performing an exact, case-insensitive match of the @code and @assigningAuthorityName attributes of $id.
 : @return all items in $items which match as above
 : @since 1.0
 : 
:)
declare function csd:filter_by_other_id($items as item()*,$id as item()) as item()* 
{
       if ($id/@assigningAuthorityName) 
       then 
           let $aaName := fn:upper-case($id/@assigningAuthorityName	) 
           let $code := fn:upper-case($id/@code)		
           return $items[ 
                          otherID[ 
                            fn:upper-case(@assigningAuthorityName)=$aaName
                            and
 			   fn:upper-case(@code)=$code
                         ]
                        ]   
        else $items
};




(:~
 : this function accepts a list of items to filter by their common name
 :
 : @param $items - a list of items to filter by their common name
 : @param $name - an xs:string, if specified, to filter the $items list selecting those whose child demographic/name/commonName child-element whose text content contains the text content of $name (case insensitive)
 : @return all items in $items which match as above
 : @since 1.0
 : 
:)
declare function csd:filter_by_common_name($items as item()*, $name as item()) as item()*
{
       if (not($name = ''))
	 then
	 let $u_name:= fn:upper-case($name)
	 for $item in $items
	 let $matches:= 
	   for $name in $item/demographic/name/commonName 
	     return if (contains(upper-case($name),$u_name)) then ($name) else ()
	 where count($matches) > 0
	 return $item
       else $items
};

(:~
 : this function accepts a list of items to filter by their surname
 :
 : @param $items - a list of items to filter by their surname
 : @param $name - an xs:string, if specified, to filter the $items list selecting those whose child demographic/name/surname child-element whose text content contains the text content of $name (case insensitive)
 : @return all items in $items which match as above
 : @since 1.0
 : 
:)
declare function csd:filter_by_surname($items as item()*, $name as item()) as item()*
{
       if (not($name = ''))
       then
	 let $u_name:= fn:upper-case($name)
	 for $item in $items
	 let $matches:= 
	   for $name in $item/demographic/name/surname
	     return if (contains(upper-case($name),$u_name)) then ($name) else ()
	 where count($matches) > 0
	 return $item
       else $items
};

(:~
 : this function accepts a list of items to filter by the start of their surname
 :
 : @param $items - a list of items to filter by their surname
 : @param $name - an xs:string, if specified, to filter the $items list selecting those whose child demographic/name/surname child-element whose text content starts with the text content of $name (case insensitive)
 : @return all items in $items which match as above
 : @since 1.0
 : 
:)
declare function csd:filter_by_surname_starts_with($items as item()*, $name as item()) as item()*
{
       if (not($name = '')) 
       then
	 let $u_name:= fn:upper-case($name)
	 for $item in $items
	 let $matches:= 
	   for $name in $item/demographic/name/surname
	     return if (starts-with(upper-case($name),$u_name)) then ($name) else ()
	 where count($matches) > 0
	 return $item
       else $items
};


(:~
 : this function accepts a list of items to filter by their forename
 :
 : @param $items - a list of items to filter by their forename
 : @param $name - an xs:string, if specified, to filter the $items list selecting those whose child demographic/name/forename child-element whose text content contains the text content of $name (case insensitive)
 : @return all items in $items which match as above
 : @since 1.0
 : 
:)
declare function csd:filter_by_forename($items as item()*, $name as item()) as item()*
{
       if (not($name = '')) 
       then
	 let $u_name:= fn:upper-case($name)
	 for $item in $items
	 let $matches:= 
	   for $name in $item/demographic/name/forename
	     return if (contains(upper-case($name),$u_name)) then ($name) else ()
	 where count($matches) > 0
	 return $item
       else $items
};


(:~
 : this function accepts a list of items to filter by the start of their forename
 :
 : @param $items - a list of items to filter by their forename
 : @param $name - an xs:string, if specified, to filter the $items list selecting those whose child demographic/name/forename child-element whose text content starts with the text content of $name (case insensitive)
 : @return all items in $items which match as above
 : @since 1.0
 : 
:)
declare function csd:filter_by_forename_starts_with($items as item()*, $name as item()) as item()*
{
       if (not($name ='')) 
       then
	 let $u_name:= fn:upper-case($name)
	 for $item in $items
	 let $matches:= 
	   for $name in $item/demographic/name/forename
	     return if (starts-with(upper-case($name),$u_name)) then ($name) else ()
	 where count($matches) > 0
	 return $item
       else $items
};



(:~
 : this function accepts a list of items to filter by their record details
 :
 : @param $items - a list of items to filter by their record details
 : @param $record - a csd:record, if specified, to filter the $items list selecting those whose child record/@status matches $record/@status exactly (case insensitive) if $record/@status is presnet non-empty and record/@updated is at least $record/@updated if the later is present and non-empty
 : @return all items in $items which match as above
 : @since 1.0
 : 
:)
declare function csd:filter_by_record($items as item()*, $record as item()) as item()* 
{
    let $items1:= 
        if (not($record/@status) )
        then $items
        else 
             let $status:= $record/@status
             return $items[record/@status = $status]
    return 
        if (not($record/@updated) ) 
        then $items1
        else $items1[record/@updated >= $record/@updated ]
            
};

(:~
 : this function accepts a list of items to limit to a subset
 :
 : @param $items - a list of items to limit
 : @param $start - a start index for limiting the item list.  If not specified then defaults to 1
 : @param $max - a maximum number of results to return.  If negattive or not specified returns all restults.
 : @return all items in $items which match as above
 : @since 1.0
 : 
:)
declare function csd:limit_items($items as item()*, $start as item(),$max as item()) as item()* 
{
        if (not(fn:number($start)) or xs:integer($start) < 1)
        then if (not(fn:number($max)) or xs:integer($max) < 0)
            then $items
            else $items[position() <= xs:integer($max)]
        else if (fn:number($max) and xs:integer($max) >= 0) 
        then $items[position() >= xs:integer($start) and position() < (xs:integer($start) + xs:integer($max))]
        else $items[position() >= xs:integer($start)]
        
 };


(:~
 : filters by the parent entities (applicable only to oragnization)
 :
 : @param $items - a list of items to filter by their record details
 : @param $orgs - a list of organizations that to filter $items against.  A member of $items is kept if there is at least one member of $orgs to which it is associated to
 : @return all items in $items which match as above
 : @since 1.0
 : 
:)

declare function csd:filter_by_parent($items as item()*,$parent as item()*) as item()*
{
  let $entryID:= $parent/@entryID
  return 
    if (not(exists($entryID)))
    then $items
    else $items[./parent[@entryID = $entryID]]
};


(:~
 : this function accepts a list of items to filter against a list of organizations
 :
 : @param $items - a list of items to filter by their record details
 : @param $orgs - a list of organizations that to filter $items against.  A member of $items is kept if there is at least one member of $orgs to which it is associated to
 : @return all items in $items which match as above
 : @since 1.0
 : 
:)

declare function csd:filter_by_organizations($items as item()*,$orgs as item()*) as item()*
{
    if (count($orgs) = 0 
       or not ($orgs[1]/text())
    ) 
    then  $items
    else  
           let $org := $orgs[1]/text()
           return csd:filter_by_organizations(
	     $items[organizations/organization[@entryID = $org]],
	     fn:subsequence($orgs,2))
  
};


(:~
 : this function accepts a list of items to filter against a list of facilities
 :
 : @param $items - a list of items to filter by their record details
 : @param $orgs - a list of facilities that to filter $items against.  A member of $items is kept if there is at least one member of $facs to which it is associated to
 : @return all items in $items which match as above
 : @since 1.0
 : 
:)
declare function csd:filter_by_facilities($items as item()*,$facs as item()*) as item()*
{
    if (count($facs) = 0 
       or not ($facs[1]/text())
    ) 
    then  $items
    else  
           let $fac := $facs[1]/text()
           return csd:filter_by_facilities(
	     $items[facilities/facility[@entryID = $fac]],
	     fn:subsequence($facs,2))
};





(:~
 : this function accepts a list of organizations and augments it to invclude all (grand-)*child organizations that are present within the given organization directory
 : @param $orgs - a list of organizations
 : @param $orgdir - the organization directory we are looking within to find (grand-)*child organizations
 : @return all organizations of $orgdir which are (grand-)*child organization of the list or given organizations $orgs. includes $orgs.
:)
declare function csd:join_child_organizations($orgs as item()*,$orgdir as item()) as item()* 
{
     if (count($orgs) = 0)
     then ()
     else 
        csd:get_child_organizations($orgs[1],$orgdir)
        union
        csd:join_child_organizations(fn:subsequence($orgs,2),$orgdir)
};


(:~
 : this function returns a list of all (grand-)*child organizations of a given organization with the given organization directory
 : @param $org - an organization
 : @param $orgdir - the organization directory we are looking within to find (grand-)*child organizations
 : @return all organizations of $orgdir which are (grand-)*child organization of the list or given organization $org. includes $org.
:)
declare function csd:get_child_organizations($org as item(),$orgdir as item()) as item()* 
{
    if (not($org)) 
    then ()
    else 
       let $root := fn:upper-case($org/@root) 
       let $extension := fn:upper-case($org/@extension)
       let $child_orgs := $orgdir/organization[
                               fn:upper-case(parent/@root)=$root 
                               and fn:upper-case(parent/@extension)=$extension
                               ]                        
       return ($org,csd:join_child_organizations($child_orgs,$orgdir))
};

(:~
 : this function returns a list of all (grand-)*parent organizations of a given organization with the given organization directory
 : @param $org - an organization
 : @param $orgdir - the organization directory we are looking within to find (grand-)*parent organizations
 : @return all organizations of $orgdir which are (grand-)*parent organization of the list or given organization $org. includes $org.
:)
declare function csd:get_parent_organizations($org as item(),$orgdir as item()) as item()* 
{
    if (not($org/parent/@root))
    then $org
    else
       let $root := fn:upper-case($org/parent/@root) 
       let $extension := fn:upper-case($org/parent/@extension)
       return (
                $org , 
               csd:get_parent_organizations(
                    $orgdir/organization[
                        fn:upper-case(@root)=$root and fn:upper-case(@extension)=$extension
                        ],
                    $orgdir
                    )
               )
};

(:~
 : this function accepts a list of organizations and augments it to invclude all (grand-)*parent organizations that are present within the given organization directory
 : @param $orgs - a list of organizations
 : @param $orgdir - the organization directory we are looking within to find (grand-)*parent organizations
 : @return all organizations of $orgdir which are (grand-)*parent organization of the list or given organizations $orgs. includes $orgs.
:)
declare function csd:join_parent_organizations($orgs as item()*,$orgdir as item()) as item()* 
{
     if (count($orgs) = 0)
     then ()
     else 
        csd:get_parent_organizations($orgs[1],$orgdir)
        union
        csd:join_parent_organizations(fn:subsequence($orgs,2),$orgdir)
};


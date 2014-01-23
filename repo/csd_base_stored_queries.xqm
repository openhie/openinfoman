(:~
: This is a module contatining the required stored queries for Care Services Discovery
: @version 1.0
: @see https://github.com/his-interop/openinfoman @see http://ihe.net
:
:)
module namespace csd_bsq = "https://github.com/his-interop/openinfoman/csd_bsq";

import module namespace csd = "urn:ihe:iti:csd:2013" at "csd_base_library.xqm";

declare default element  namespace   "urn:ihe:iti:csd:2013";

declare variable $csd_bsq:stored_functions :=
(
   <function uuid='4e8bbeb9-f5f5-11e2-b778-0800200c9a66' 
   	     method='csd_bsq:provider_search'	    
 	     content-type='text/xml; charset=utf-8'      
	     />,
   <function uuid='dc6aedf0-f609-11e2-b778-0800200c9a66'
   	     method='csd_bsq:organization_search'	    
 	     content-type='text/xml; charset=utf-8'      
	     />,
   <function uuid='e3d8ecd0-f605-11e2-b778-0800200c9a66'
   	     method='csd_bsq:service_search'	    
 	     content-type='text/xml; charset=utf-8'      
	     />,
   <function uuid='c7640530-f600-11e2-b778-0800200c9a66'
   	     method='csd_bsq:facility_search'	    
 	     content-type='text/xml; charset=utf-8'      
	     />
);



declare function csd_bsq:provider_search($requestParams, $doc) as element() 
{
<CSD xmlns:csd="urn:ihe:iti:csd:2013"  >
  <organizationDirectory/>
  <serviceDirectory/>
  <facilityDirectory/>
  <providerDirectory>
    {

      let $provs0 := if (exists($requestParams/id))
	then csd:filter_by_primary_id($doc/CSD/providerDirectory/*,$requestParams/id)
      else $doc/CSD/providerDirectory/*

      let $provs1 := if(exists($requestParams/otherID))
	then csd:filter_by_other_id($provs0,$requestParams/otherID)
      else $provs0
         
      let $provs2 := if(exists($requestParams/commonName))
	then csd:filter_by_common_name($provs1,$requestParams/commonName)
      else $provs1
    
      let $provs3 := if (exists($requestParams/codedType))
	then csd:filter_by_coded_type($provs2,$requestParams/codedType) 
      else $provs2
   
      let $provs4 := if (exists($requestParams/address/addressLine))
	then csd:filter_by_address($provs3, $requestParams/address/addressLine) 
      else $provs3

      let $provs5 :=  if (exists($requestParams/record)) 
	then csd:filter_by_record($provs4,$requestParams/record)      
      else  $provs4

      return if (exists($requestParams/start)) then
	if (exists($requestParams/max)) 
	  then csd:limit_items($provs5,$requestParams/start,$requestParams/max)         
	else csd:limit_items($provs5,$requestParams/start,<max/>)         
      else
	if (exists($requestParams/max)) 
	  then csd:limit_items($provs5,<start/>,$requestParams/max)         
	else $provs5

    }     
  </providerDirectory>
</CSD>

};




declare function csd_bsq:organization_search($requestParams, $doc) as element() 
{
<CSD xmlns:csd="urn:ihe:iti:csd:2013"  >
  <organizationDirectory>
    {
      let $orgs0 := if (exists($requestParams/id))
	then csd:filter_by_primary_id($doc/CSD/organizationDirectory/*,$requestParams/id)
	else $doc/CSD/organizationDirectory/*
         
      let $orgs1 := if (exists($requestParams/primaryName))
	then csd:filter_by_primary_name($orgs0,$requestParams/primaryName)
      else $orgs0
         
      let $orgs2 := if(exists($requestParams/name))
	then csd:filter_by_name($orgs1,$requestParams/name)
      else $orgs1
    
      let $orgs3 := if(exists($requestParams/codedType))
	then csd:filter_by_coded_type($orgs2,$requestParams/codedType) 
	else $orgs2
   
      let $orgs4 :=if (exists($requestParams/address/addressLine))
	then csd:filter_by_address($orgs3, $requestParams/address/addressLine) 
	else $orgs3
      
      let $orgs5 := if (exists($requestParams/record))
	then csd:filter_by_record($orgs4,$requestParams/record)      
      else $orgs4

      let $orgs6 := if (exists($requestParams/otherID))
	then csd:filter_by_other_id($orgs5,$requestParams/otherID)
      else $orgs5

      return if (exists($requestParams/start)) then
	if (exists($requestParams/max)) 
	  then csd:limit_items($orgs6,$requestParams/start,$requestParams/max)         
	else csd:limit_items($orgs6,$requestParams/start,<max/>)         
      else
	if (exists($requestParams/max)) 
	  then csd:limit_items($orgs6,<start/>,$requestParams/max)         
	else $orgs6

    }     
  </organizationDirectory>
  <serviceDirectory/>
  <facilityDirectory/>
  <providerDirectory/>
</CSD>
};


declare function csd_bsq:facility_search($requestParams, $doc) as element() 
{
<CSD xmlns:csd="urn:ihe:iti:csd:2013"  >
  <organizationDirectory/>
  <serviceDirectory/>
  <facilityDirectory>
    {
      let $facs0 := if (exists($requestParams/id))
	then csd:filter_by_primary_id($doc/CSD/facilityDirectory/*,$requestParams/id)
      else $doc/CSD/facilityDirectory/*
         
      let $facs1 := if (exists($requestParams/primaryName))
	then csd:filter_by_primary_name($facs0,$requestParams/primaryName)
      else $facs0
         
      let $facs2 := if (exists($requestParams/name))
	then csd:filter_by_name($facs1,$requestParams/name)
      else $facs1
    
      let $facs3 := if(exists($requestParams/codedType))
	then csd:filter_by_coded_type($facs2,$requestParams/codedType) 
      else $facs2
   
      let $facs4 := if(exists($requestParams/address/addressLine))
	then csd:filter_by_address($facs3, $requestParams/address/addressLine) 
      else $facs3

      let $facs5 := if (exists($requestParams/record))
	then csd:filter_by_record($facs4,$requestParams/record)      
      else $facs4

      let $facs6 := if(exists($requestParams/otherID))
	then csd:filter_by_other_id($facs5,$requestParams/otherID)      
      else $facs5

      return if (exists($requestParams/start)) then
	if (exists($requestParams/max)) 
	  then csd:limit_items($facs6,$requestParams/start,$requestParams/max)         
	else csd:limit_items($facs6,$requestParams/start,<max/>)         
      else
	if (exists($requestParams/max)) 
	  then csd:limit_items($facs6,<start/>,$requestParams/max)         
	else $facs6


    }     
  </facilityDirectory>
  <providerDirectory/>
</CSD>
};


declare function csd_bsq:service_search($requestParams, $doc) as element() 
{
<CSD xmlns:csd="urn:ihe:iti:csd:2013"  >
  <organizationDirectory/>
  <serviceDirectory>
    {
      let $svcs0 := if (exists($requestParams/id))
	then csd:filter_by_primary_id($doc/CSD/serviceDirectory/*,$requestParams/id)
      else $doc/CSD/serviceDirectory/*
    	
      let $svcs1 := if(exists($requestParams/codedType))
	then csd:filter_by_coded_type($svcs0,$requestParams/codedType) 
      else $svcs0

      let $svcs2 :=  if (exists($requestParams/record))
	then csd:filter_by_record($svcs1,$requestParams/record)
      else $svcs1

      return if (exists($requestParams/start)) then
	if (exists($requestParams/max)) 
	  then csd:limit_items(svcs2,$requestParams/start,$requestParams/max)         
	else csd:limit_items(svcs2,$requestParams/start,<max/>)         
      else
	if (exists($requestParams/max)) 
	  then csd:limit_items(svcs2,<start/>,$requestParams/max)         
	else svcs2

    }     
  </serviceDirectory>
  <facilityDirectory/>
  <providerDirectory/>
</CSD>
    
};

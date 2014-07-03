(:~
: This is a module contatining the required stored queries for Care Services Discovery
: @version 1.0
: @see https://github.com/openhie/openinfoman @see http://ihe.net
:
:)
module namespace csd_bsq = "https://github.com/openhie/openinfoman/csd_bsq";

import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";

declare default element  namespace   "urn:ihe:iti:csd:2013";



declare function csd_bsq:provider_search($requestParams, $doc) as element() 
{

 csd_bl:wrap_providers(
      let $provs0 := if (exists($requestParams/id))
	then csd_bl:filter_by_primary_id($doc/CSD/providerDirectory/*,$requestParams/id)
      else $doc/CSD/providerDirectory/*

      let $provs1 := if(exists($requestParams/otherID))
	then csd_bl:filter_by_other_id($provs0,$requestParams/otherID)
      else $provs0
         
      let $provs2 := if(exists($requestParams/commonName))
	then csd_bl:filter_by_common_name($provs1,$requestParams/commonName)
      else $provs1
    
      let $provs3 := if (exists($requestParams/codedType))
	then csd_bl:filter_by_coded_type($provs2,$requestParams/codedType) 
      else $provs2
   
      let $provs4 := if (exists($requestParams/address/addressLine))
	then csd_bl:filter_by_demographic_address($provs3, $requestParams/address/addressLine) 
      else $provs3

      let $provs5 :=  if (exists($requestParams/record)) 
	then csd_bl:filter_by_record($provs4,$requestParams/record)      
      else  $provs4

      return if (exists($requestParams/start)) then
	if (exists($requestParams/max)) 
	  then csd_bl:limit_items($provs5,$requestParams/start,$requestParams/max)         
	else csd_bl:limit_items($provs5,$requestParams/start,<max/>)         
      else
	if (exists($requestParams/max)) 
	  then csd_bl:limit_items($provs5,<start/>,$requestParams/max)         
	else $provs5
)

};




declare function csd_bsq:organization_search($requestParams, $doc) as element() 
{
 csd_bl:wrap_organizations(
      let $orgs0 := if (exists($requestParams/id))
	then csd_bl:filter_by_primary_id($doc/CSD/organizationDirectory/*,$requestParams/id)
	else $doc/CSD/organizationDirectory/*
         
      let $orgs1 := if (exists($requestParams/primaryName))
	then csd_bl:filter_by_primary_name($orgs0,$requestParams/primaryName)
      else $orgs0
         
      let $orgs2 := if(exists($requestParams/name))
	then csd_bl:filter_by_name($orgs1,$requestParams/name)
      else $orgs1
    
      let $orgs3 := if(exists($requestParams/codedType))
	then csd_bl:filter_by_coded_type($orgs2,$requestParams/codedType) 
	else $orgs2
   
      let $orgs4 :=if (exists($requestParams/address/addressLine))
	then csd_bl:filter_by_address($orgs3, $requestParams/address/addressLine) 
	else $orgs3
      
      let $orgs5 := if (exists($requestParams/record))
	then csd_bl:filter_by_record($orgs4,$requestParams/record)      
      else $orgs4

      let $orgs6 := if (exists($requestParams/otherID))
	then csd_bl:filter_by_other_id($orgs5,$requestParams/otherID)
      else $orgs5

      return if (exists($requestParams/start)) then
	if (exists($requestParams/max)) 
	  then csd_bl:limit_items($orgs6,$requestParams/start,$requestParams/max)         
	else csd_bl:limit_items($orgs6,$requestParams/start,<max/>)         
      else
	if (exists($requestParams/max)) 
	  then csd_bl:limit_items($orgs6,<start/>,$requestParams/max)         
	else $orgs6
)
};


declare function csd_bsq:facility_search($requestParams, $doc) as element() 
{
csd_bl:wrap_facilities(
      let $facs0 := if (exists($requestParams/id))
	then csd_bl:filter_by_primary_id($doc/CSD/facilityDirectory/*,$requestParams/id)
      else $doc/CSD/facilityDirectory/*
         
      let $facs1 := if (exists($requestParams/primaryName))
	then csd_bl:filter_by_primary_name($facs0,$requestParams/primaryName)
      else $facs0
         
      let $facs2 := if (exists($requestParams/name))
	then csd_bl:filter_by_name($facs1,$requestParams/name)
      else $facs1
    
      let $facs3 := if(exists($requestParams/codedType))
	then csd_bl:filter_by_coded_type($facs2,$requestParams/codedType) 
      else $facs2
   
      let $facs4 := if(exists($requestParams/address/addressLine))
	then csd_bl:filter_by_address($facs3, $requestParams/address/addressLine) 
      else $facs3

      let $facs5 := if (exists($requestParams/record))
	then csd_bl:filter_by_record($facs4,$requestParams/record)      
      else $facs4

      let $facs6 := if(exists($requestParams/otherID))
	then csd_bl:filter_by_other_id($facs5,$requestParams/otherID)      
      else $facs5

      return if (exists($requestParams/start)) then
	if (exists($requestParams/max)) 
	  then csd_bl:limit_items($facs6,$requestParams/start,$requestParams/max)         
	else csd_bl:limit_items($facs6,$requestParams/start,<max/>)         
      else
	if (exists($requestParams/max)) 
	  then csd_bl:limit_items($facs6,<start/>,$requestParams/max)         
	else $facs6

)
};


declare function csd_bsq:service_search($requestParams, $doc) as element() 
{
csd_bl:wrap_services(
      let $svcs0 := if (exists($requestParams/id))
	then csd_bl:filter_by_primary_id($doc/CSD/serviceDirectory/*,$requestParams/id)
      else $doc/CSD/serviceDirectory/*
    	
      let $svcs1 := if(exists($requestParams/codedType))
	then csd_bl:filter_by_coded_type($svcs0,$requestParams/codedType) 
      else $svcs0

      let $svcs2 :=  if (exists($requestParams/record))
	then csd_bl:filter_by_record($svcs1,$requestParams/record)
      else $svcs1

      return if (exists($requestParams/start)) then
	if (exists($requestParams/max)) 
	  then csd_bl:limit_items($svcs2,$requestParams/start,$requestParams/max)         
	else csd_bl:limit_items($svcs2,$requestParams/start,<max/>)         
      else
	if (exists($requestParams/max)) 
	  then csd_bl:limit_items($svcs2,<start/>,$requestParams/max)         
	else $svcs2

)    
};

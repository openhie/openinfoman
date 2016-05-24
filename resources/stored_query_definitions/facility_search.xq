import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare  variable $careServicesRequest as item() external;



(: 
   The query will be executed against the root element of the CSD document.
    
   The dynamic context of this query has $careServicesRequest/requestParams set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 
<CSD xmlns:csd="urn:ihe:iti:csd:2013"  >
  <organizationDirectory/>
  <serviceDirectory/>
  <facilityDirectory>
    {
      let $facs0 := if (exists($careServicesRequest/requestParams/id))
	then csd_bl:filter_by_primary_id(/CSD/facilityDirectory/*,$careServicesRequest/requestParams/id)
      else /CSD/facilityDirectory/*
         
      let $facs1 := if (exists($careServicesRequest/requestParams/primaryName))
	then csd_bl:filter_by_primary_name($facs0,$careServicesRequest/requestParams/primaryName)
      else $facs0
         
      let $facs2 := if (exists($careServicesRequest/requestParams/name))
	then csd_bl:filter_by_name($facs1,$careServicesRequest/requestParams/name)
      else $facs1
    
      let $facs3 := if(exists($careServicesRequest/requestParams/codedType))
	then csd_bl:filter_by_coded_type($facs2,$careServicesRequest/requestParams/codedType) 
      else $facs2
   
      let $facs4 := if(exists($careServicesRequest/requestParams/address/addressLine))
	then csd_bl:filter_by_address($facs3, $careServicesRequest/requestParams/address/addressLine) 
      else $facs3

      let $facs5 := if (exists($careServicesRequest/requestParams/record))
	then csd_bl:filter_by_record($facs4,$careServicesRequest/requestParams/record)      
      else $facs4

      let $facs6 := if(exists($careServicesRequest/requestParams/otherID))
	then csd_bl:filter_by_other_id($facs5,$careServicesRequest/requestParams/otherID)      
      else $facs5


      let $facs7 :=  if (exists($careServicesRequest/requestParams/organizations/organization)) 
	then (csd_bl:filter_by_organizations($facs6,$careServicesRequest/requestParams/organizations/organization)      )
      else  ($facs6)
	

      return if (exists($careServicesRequest/requestParams/start)) then
	if (exists($careServicesRequest/requestParams/max)) 
	  then csd_bl:limit_items($facs7,$careServicesRequest/requestParams/start,$careServicesRequest/requestParams/max)         
	else csd_bl:limit_items($facs7,$careServicesRequest/requestParams/start,<max/>)         
      else
	if (exists($careServicesRequest/requestParams/max)) 
	  then csd_bl:limit_items($facs7,<start/>,$careServicesRequest/requestParams/max)         
	else $facs7


    }     
  </facilityDirectory>
  <providerDirectory/>
</CSD>
    
import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
    
   The dynamic context of this query has $careServicesRequest/requestParams set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 


<CSD xmlns:csd="urn:ihe:iti:csd:2013"  >
  <organizationDirectory>
    {
      let $orgs0 := if (exists($careServicesRequest/requestParams/id))
	then csd_bl:filter_by_primary_id(/CSD/organizationDirectory/*,$careServicesRequest/requestParams/id)
      else /CSD/organizationDirectory/*
         
      let $orgs1 := if (exists($careServicesRequest/requestParams/primaryName))
	then csd_bl:filter_by_primary_name($orgs0,$careServicesRequest/requestParams/primaryName)
      else $orgs0
         
      let $orgs2 := if(exists($careServicesRequest/requestParams/name))
	then csd_bl:filter_by_name($orgs1,$careServicesRequest/requestParams/name)
      else $orgs1
    
      let $orgs3 := if(exists($careServicesRequest/requestParams/codedType))
	then csd_bl:filter_by_coded_type($orgs2,$careServicesRequest/requestParams/codedType)
      else $orgs2
   
      let $orgs4 :=if (exists($careServicesRequest/requestParams/address/addressLine))
	then csd_bl:filter_by_address($orgs3, $careServicesRequest/requestParams/address/addressLine)
      else $orgs3
      
      let $orgs5 := if (exists($careServicesRequest/requestParams/record))
	then csd_bl:filter_by_record($orgs4,$careServicesRequest/requestParams/record)
      else $orgs4

      let $orgs6 := if (exists($careServicesRequest/requestParams/otherID))
	then csd_bl:filter_by_other_id($orgs5,$careServicesRequest/requestParams/otherID)
      else $orgs5

      let $orgs7 := if (exists($careServicesRequest/requestParams/parent))
	then csd_bl:filter_by_parent($orgs5,$careServicesRequest/requestParams/parent)
      else $orgs6

      return if (exists($careServicesRequest/requestParams/start)) then
	if (exists($careServicesRequest/requestParams/max))
	  then csd_bl:limit_items($orgs7,$careServicesRequest/requestParams/start,$careServicesRequest/requestParams/max)
	else csd_bl:limit_items($orgs7,$careServicesRequest/requestParams/start,<max/>)
      else
	if (exists($careServicesRequest/requestParams/max))
	  then csd_bl:limit_items($orgs7,<start/>,$careServicesRequest/requestParams/max)
	else $orgs7

    }     
  </organizationDirectory>
  <serviceDirectory/>
  <facilityDirectory/>
  <providerDirectory/>
</CSD>

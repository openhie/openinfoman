import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
    
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 


<CSD xmlns:csd="urn:ihe:iti:csd:2013"  >
  <organizationDirectory>
    {
      let $orgs0 := if (exists($careServicesRequest/id))
	then csd_bl:filter_by_primary_id(/CSD/organizationDirectory/*,$careServicesRequest/id)
      else /CSD/organizationDirectory/*
         
      let $orgs1 := if (exists($careServicesRequest/primaryName))
	then csd_bl:filter_by_primary_name($orgs0,$careServicesRequest/primaryName)
      else $orgs0
         
      let $orgs2 := if(exists($careServicesRequest/name))
	then csd_bl:filter_by_name($orgs1,$careServicesRequest/name)
      else $orgs1
    
      let $orgs3 := if(exists($careServicesRequest/codedType))
	then csd_bl:filter_by_coded_type($orgs2,$careServicesRequest/codedType)
      else $orgs2
   
      let $orgs4 :=if (exists($careServicesRequest/address/addressLine))
	then csd_bl:filter_by_address($orgs3, $careServicesRequest/address/addressLine)
      else $orgs3
      
      let $orgs5 := if (exists($careServicesRequest/record))
	then csd_bl:filter_by_record($orgs4,$careServicesRequest/record)
      else $orgs4

      let $orgs6 := if (exists($careServicesRequest/otherID))
	then csd_bl:filter_by_other_id($orgs5,$careServicesRequest/otherID)
      else $orgs5

      let $orgs7 := if (exists($careServicesRequest/parent))
	then csd_bl:filter_by_parent($orgs5,$careServicesRequest/parent)
      else $orgs6

      return if (exists($careServicesRequest/start)) then
	if (exists($careServicesRequest/max))
	  then csd_bl:limit_items($orgs7,$careServicesRequest/start,$careServicesRequest/max)
	else csd_bl:limit_items($orgs7,$careServicesRequest/start,<max/>)
      else
	if (exists($careServicesRequest/max))
	  then csd_bl:limit_items($orgs7,<start/>,$careServicesRequest/max)
	else $orgs6

    }     
  </organizationDirectory>
  <serviceDirectory/>
  <facilityDirectory/>
  <providerDirectory/>
</CSD>

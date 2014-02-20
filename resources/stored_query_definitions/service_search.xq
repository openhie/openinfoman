import module namespace csd = "urn:ihe:iti:csd:2013" at "../repo/csd_base_library.xqm";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
    
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 

<CSD xmlns:csd="urn:ihe:iti:csd:2013"  >
  <organizationDirectory/>
  <serviceDirectory>
    {
      let $svcs0 := if (exists($careServicesRequest/id))
	then csd:filter_by_primary_id(/CSD/serviceDirectory/*,$careServicesRequest/id)
      else /CSD/serviceDirectory/*
    	
      let $svcs1 := if(exists($careServicesRequest/codedType))
	then csd:filter_by_coded_type($svcs0,$careServicesRequest/codedType) 
      else $svcs0

      let $svcs2 :=  if (exists($careServicesRequest/record))
	then csd:filter_by_record($svcs1,$careServicesRequest/record)
      else $svcs1

      return if (exists($careServicesRequest/start)) then
	if (exists($careServicesRequest/max)) 
	  then csd:limit_items($svcs2,$careServicesRequest/start,$careServicesRequest/max)         
	else csd:limit_items($svcs2,$careServicesRequest/start,<max/>)         
      else
	if (exists($careServicesRequest/max)) 
	  then csd:limit_items($svcs2,<start/>,$careServicesRequest/max)         
	else $svcs2

    }     
  </serviceDirectory>
  <facilityDirectory/>
  <providerDirectory/>
</CSD>

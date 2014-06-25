import module namespace csd_bl = "https://github.com/his-interop/openinfoman/csd_bl";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
    
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 

<CSD xmlns:csd="urn:ihe:iti:csd:2013"  >
  <organizationDirectory/>
  <serviceDirectory/>
  <facilityDirectory/>
  <providerDirectory>
    {

      let $provs0 := if (exists($careServicesRequest/id))
	then csd_bl:filter_by_primary_id(/CSD/providerDirectory/*,$careServicesRequest/id)
      else /CSD/providerDirectory/*

      let $provs1 := if(exists($careServicesRequest/otherID))
	then csd_bl:filter_by_other_id($provs0,$careServicesRequest/otherID)
      else $provs0
         
      let $provs2 := if(exists($careServicesRequest/commonName))
	then csd_bl:filter_by_common_name($provs1,$careServicesRequest/commonName)
      else $provs1
    
      let $provs3 := if (exists($careServicesRequest/codedType))
	then csd_bl:filter_by_coded_type($provs2,$careServicesRequest/codedType) 
      else $provs2
   
      let $provs4 := if (exists($careServicesRequest/address/addressLine))
	then csd_bl:filter_by_demographic_address($provs3, $careServicesRequest/address/addressLine) 
      else $provs3

      let $provs5 :=  if (exists($careServicesRequest/record)) 
	then csd_bl:filter_by_record($provs4,$careServicesRequest/record)      
      else  $provs4

      return if (exists($careServicesRequest/start)) then
	if (exists($careServicesRequest/max)) 
	  then csd_bl:limit_items($provs5,$careServicesRequest/start,$careServicesRequest/max)         
	else csd_bl:limit_items($provs5,$careServicesRequest/start,<max/>)         
      else
	if (exists($careServicesRequest/max)) 
	  then csd_bl:limit_items($provs5,<start/>,$careServicesRequest/max)         
	else $provs5

    }     
  </providerDirectory>
</CSD>

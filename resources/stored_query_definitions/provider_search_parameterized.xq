import module namespace csd = "urn:ihe:iti:csd:2013" at "../repo/csd_base_library.xqm";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare namespace xsd "http://www.w3.org/2001/XMLSchema";
declare variable $careServicesRequest as item() external;
declare variable $id as xsd:string external;
declare variable $codedType as item() external;

(: 
   The query will be executed against the root element of the CSD document.
    

   and limit paramaters as sent by the Service Finder
:) 

<CSD xmlns:csd="urn:ihe:iti:csd:2013"  >
  <organizationDirectory/>
  <serviceDirectory/>
  <facilityDirectory/>
  <providerDirectory>
    {

      let $provs0 := if (exists($id))
	then csd:filter_by_primary_id(/CSD/providerDirectory/*,$id)
      else /CSD/providerDirectory/*

      let $provs1 := if(exists($otherID))
	then csd:filter_by_other_id($provs0,$otherID)
      else $provs0
         
      let $provs2 := if(exists($commonName))
	then csd:filter_by_common_name($provs1,$commonName)
      else $provs1
    
      let $provs3 := if (exists($codedType))
	then csd:filter_by_coded_type($provs2,$codedType) 
      else $provs2
   
      let $provs4 := if (exists($address/addressLine))
	then csd:filter_by_demographic_address($provs3, $address/addressLine) 
      else $provs3

      let $provs5 :=  if (exists($record)) 
	then csd:filter_by_record($provs4,$record)      
      else  $provs4

      return if (exists($start)) then
	if (exists($max)) 
	  then csd:limit_items($provs5,$start,$max)         
	else csd:limit_items($provs5,$start,<max/>)         
      else
	if (exists($max)) 
	  then csd:limit_items($provs5,<start/>,$max)         
	else $provs5

    }     
  </providerDirectory>
</CSD>

(:~
: This is a module contatining the required stored queries for Care Services Discovery
: @version 1.0
: @see https://github.com/his-interop/openinfoman @see http://ihe.net
:
:)
module namespace csd_bsq = "https://github.com/his-interop/openinfoman/csd_bsq";

import module namespace csd = "urn:ihe:iti:csd:2013" at "csd_base_library.xqm";

declare default element  namespace   "urn:ihe:iti:csd:2013";


declare function csd_bsq:provider_search($requestParams, $doc) as element() 
{
<CSD xmlns:csd="urn:ihe:iti:csd:2013"  >
  <organizationDirectory/>
  <serviceDirectory/>
  <facilityDirectory/>
  <providerDirectory>
    {

      let $provs0 := csd:filter_by_primary_id($doc/CSD/providerDirectory/*,$requestParams/id)

      let $provs1 := csd:filter_by_other_id($provs0,$requestParams/otherID)
         
      let $provs2 := csd:filter_by_common_name($provs1,$requestParams/commonName)
    
      let $provs3 := csd:filter_by_coded_type($provs2,$requestParams/type) 
   
      let $provs4 := csd:filter_by_address($provs3, $requestParams/address/addressLine) 

      let $provs5 :=  csd:filter_by_record($provs4,$requestParams/record)      

      return csd:limit_items($provs5,$requestParams/start,$requestParams/max)         
    }     
  </providerDirectory>
</CSD>

};




declare function csd_bsq:organization_search($requestParams, $doc) as element() 
{
<CSD xmlns:csd="urn:ihe:iti:csd:2013"  >
  <organizationDirectory>
    {
      let $orgs0 := csd:filter_by_primary_id($doc/CSD/organizationDirectory/*,$requestParams/id)
         
      let $orgs1 := csd:filter_by_primary_name($orgs0,$requestParams/primaryName)
         
      let $orgs2 := csd:filter_by_name($orgs1,$requestParams/name)
    
      let $orgs3 := csd:filter_by_coded_type($orgs2,$requestParams/codedType) 
   
      let $orgs4 := csd:filter_by_address($orgs3, $requestParams/address/addressLine) 
      
      let $orgs5 :=  csd:filter_by_record($orgs4,$requestParams/record)      

      return csd:limit_items($orgs5,$requestParams/start,$requestParams/max)         

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
      let $facs0 := csd:filter_by_primary_id($doc/CSD/facilityDirectory/*,$requestParams/id)
         
      let $facs1 := csd:filter_by_primary_name($facs0,$requestParams/primaryName)
         
      let $facs2 := csd:filter_by_name($facs1,$requestParams/name)
    
      let $facs3 := csd:filter_by_coded_type($facs2,$requestParams/codedType) 
   
      let $facs4 := csd:filter_by_address($facs3, $requestParams/address/addressLine) 

      let $facs5 :=  csd:filter_by_record($facs4,$requestParams/record)      

      return csd:limit_items($facs5,$requestParams/start,$requestParams/max)         

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
      let $svcs0 := csd:filter_by_primary_id($doc/CSD/serviceDirectory/*,$requestParams/id)
    
      let $svcs1 := csd:filter_by_coded_type($svcs0,$requestParams/codedType) 

      let $svcs2 :=  csd:filter_by_record($svcs1,$requestParams/record)

      return csd:limit_items($svcs2,$requestParams/start,$requestParams/max)   
    }     
  </serviceDirectory>
  <facilityDirectory/>
  <providerDirectory/>
</CSD>
    
};
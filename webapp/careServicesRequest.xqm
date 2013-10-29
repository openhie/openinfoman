module namespace page = 'http://basex.org/modules/web-page';
import module namespace csd = "urn:ihe:iti:csd:2013" at "../../repo/csd_base_library.xqm";
declare default element  namespace   "urn:ihe:iti:csd:2013";


declare
  %rest:path("/CSD/provider_search")
  %output:method("xml")
  %output:omit-xml-declaration("no")
  function page:providersearch() 
  as element()
{

for $doc in collection('provider_directory')
let $careServicesRequest := <careServicesRequest><id oid='2.25.309768652999692686176651983274504471835.646.1.615351552068889518564164611046405512878087'/><otherID/><commonName/><type/><addressLine/><record/><start/><max/></careServicesRequest>
where matches(document-uri($doc), 'providers.xml')
return 

<CSD xmlns:csd="urn:ihe:iti:csd:2013"  >
  <organizationDirectory/>
  <serviceDirectory/>
  <facilityDirectory/>
  <providerDirectory>
    {

      let $provs0 := csd:filter_by_primary_id($doc/CSD/providerDirectory/*,$careServicesRequest/id)

      let $provs1 := csd:filter_by_other_id($provs0,$careServicesRequest/otherID)
         
      let $provs2 := csd:filter_by_common_name($provs1,$careServicesRequest/commonName)
    
      let $provs3 := csd:filter_by_coded_type($provs2,$careServicesRequest/type) 
   
      let $provs4 := csd:filter_by_address($provs3, $careServicesRequest/address/addressLine) 

      let $provs5 :=  csd:filter_by_record($provs4,$careServicesRequest/record)      

      return csd:limit_items($provs5,$careServicesRequest/start,$careServicesRequest/max)         


    }     
  </providerDirectory>
</CSD>
};


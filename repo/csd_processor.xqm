(:~
: This is the Care Services Discovery RESTful document processor
: @version 1.0
: @see https://github.com/his-interop/openinfoman
:
:)
module namespace csd_proc = "https://github.com/his-interop/openinfoman";



declare   namespace   csd = "urn:ihe:iti:csd:2013";
declare default element  namespace   "urn:ihe:iti:csd:2013";

declare function csd_proc:process_CSR($careServicesRequest, $doc) as element() 
{

if ($careServicesRequest/function) 
then
  csd_proc:process_CSR_stored($careServicesRequest/csd:function,$doc)
else if ($careServicesRequest/expression) 
then
  csd_proc:process_CSR_adhoc($careServicesRequest/expression,$doc)
else 
  <rest:reponse>
    <http:response status="400" message="Invalid care services request.">
      <http:header name="Content-Language" value="en"/>
      <http:header name="Content-Type" value="text/html; charset=utf-8"/>
    </http:response>
  </rest:reponse>


};


declare function csd_proc:process_CSR_adhoc($expression,$doc) as element() 
{
  <rest:reponse>
    <http:response status="404" message="Ad-Hoc not imeplemented yet.">
      <http:header name="Content-Language" value="en"/>
      <http:header name="Content-Type" value="text/html; charset=utf-8"/>
    </http:response>
  </rest:reponse>


};

declare function csd_proc:lookup_stored($uuid) 
{

let $stored_functions :=
<storedFunctions>
   <function uuid='4e8bbeb9-f5f5-11e2-b778-0800200c9a66' 
   	     method='csd_proc:process_CSR_provider_search'	    
 	     content-type='text-xml'      
	     />
</storedFunctions>

return $stored_functions/function[@uuid = $uuid]

};


declare function csd_proc:process_CSR_stored($function,$doc) as element() 
{
let $stored := csd_proc:lookup_stored($function/@uuid) 
return if ($stored)
then
  let $method := function-lookup( xs:QName(text{$stored/@method}), 2)
  return if (exists($method ))
  then
      let $result :=  $method($function/requestParams,$doc)   
       return if ($function/@encapsulated) 
       then
          csd_proc:wrap_result($result,$stored/@content-type)
       else
          $result
  else
    <rest:reponse>
     <http:response status="404" message="No registered function with UUID='{$function/@uuid}.'">
      <http:header name="Content-Language" value="en"/>
      <http:header name="Content-Type" value="text/html; charset=utf-8"/>
     </http:response>
    </rest:reponse>
else
    <rest:reponse>
     <http:response status="404" message="No registered function with UUID='{$function/@uuid}.'">
      <http:header name="Content-Language" value="en"/>
      <http:header name="Content-Type" value="text/html; charset=utf-8"/>
     </http:response>
    </rest:reponse>

};

declare function csd_proc:wrap_result($result,$content-type) {
 <careServicesResponse content-type="{$content-type}"><result>{$result}</result></careServicesResponse>
};



declare function csd_proc:process_CSR_provider_search($careServicesRequest, $doc) as element() 
{
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


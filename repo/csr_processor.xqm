(:~
: This is the Care Services Discovery RESTful document processor
: @version 1.0
: @see https://github.com/his-interop/openinfoman
:
:)
module namespace csr_proc = "https://github.com/his-interop/openinfoman/csr_proc";


import module namespace csd_webconf = "https://github.com/his-interop/openinfoman/csd_webconf" at "csd_webapp_config.xqm";

declare   namespace   csd = "urn:ihe:iti:csd:2013";
declare default element  namespace   "urn:ihe:iti:csd:2013";



declare function csr_proc:process_CSR($careServicesRequest, $doc) 
{
let $func :=$careServicesRequest//csd:function
let $adhoc :=$careServicesRequest//csd:expression
return if (exists($func)) 
then
 csr_proc:process_CSR_stored($func,$doc) 
else if (exists($adhoc))
then
  csr_proc:process_CSR_adhoc($adhoc,$doc) 
else 
  <rest:response>
    <http:response status="400" message="Invalid care services request.">
      <http:header name="Content-Language" value="en"/>
      <http:header name="Content-Type" value="text/html; charset=utf-8"/>
    </http:response>
  </rest:response>


};


declare function csr_proc:process_CSR_adhoc($expression,$doc) 
{

let $expr :=serialize($expression/*)
return if ($expr) then
  let $result := xquery:eval($expr,map{"":=$doc})
  return(  
   <rest:response>
   <http:response status="200" >
      <http:header name="Content-Type" value="{$expression/@content-type}"/>
    </http:response>
  </rest:response>
  ,$result
 )
else
   <rest:response>
     <http:response status="400" message="No ad-hoc expression" />
  </rest:response> 
};



declare function csr_proc:process_CSR_stored($function,$doc) 
{
if (csd_webconf:has_stored_query($function/@uuid)) 
then
  let $result := csd_webconf:execute_stored_query($doc,$function/@uuid,$function/requestParams)
  let $content_type := csd_webconf:lookup_stored_content_type($function/@uuid)
  return if ($function/@encapsulated) 
  then
         csr_proc:wrap_result($result,$content_type)
  else
	 (<rest:response>
	   <http:response status="200" >
	     <http:header name="Content-Type" value="{$content_type}"/>
	   </http:response>
	 </rest:response>,
	 $result
	 )
else
    <rest:response>
     <http:response status="404" message="No registered function with UUID='{$function/@uuid}.'">
      <http:header name="Content-Language" value="en"/>
      <http:header name="Content-Type" value="text/html; charset=utf-8"/>
     </http:response>
    </rest:response>

};

declare function csr_proc:wrap_result($result,$content-type) {
 <careServicesResponse content-type="{$content-type}"><result>{$result}</result></careServicesResponse>
};



declare function csr_proc:create_adhoc_doc($adhoc_query,$content_type) {
let $content := if ($content_type) then $content_type else "application/xml" 
return
 <csd:careServicesRequest xmlns:csd='urn:ihe:iti:csd:2013'>
  <csd:expression content-type='{$content}'>
  {$adhoc_query}
  </csd:expression> 
</csd:careServicesRequest>     



};
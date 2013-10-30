(:~
: This is the Care Services Discovery RESTful document processor
: @version 1.0
: @see https://github.com/his-interop/openinfoman
:
:)
module namespace csr_proc = "https://github.com/his-interop/openinfoman/csr_proc";

import module namespace csd_sq = "https://github.com/his-interop/openinfoman/csd_sq" at "csd_stored_queries.xqm";


declare   namespace   csd = "urn:ihe:iti:csd:2013";
declare default element  namespace   "urn:ihe:iti:csd:2013";

declare function csr_proc:process_CSR($careServicesRequest, $doc) 
{

if ($careServicesRequest/function) 
then
  csr_proc:process_CSR_stored($careServicesRequest/csd:function,$doc)
else if ($careServicesRequest/expression) 
then
  csr_proc:process_CSR_adhoc($careServicesRequest/expression,$doc)
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

(:let $result := xquery:eval("<h2>{count(//*)}</h2>",map{"":=$doc}) :)
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
if (csd_sq:has_stored_query($function/@uuid)) 
then
  let $result := csd_sq:execute_stored_query($doc,$function/@uuid,$function/requestParams)
  let $content_type := csd_sq:lookup_stored_content_type($function/@uuid)
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





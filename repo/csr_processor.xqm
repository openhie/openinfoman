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


(:this should proabably be moved to the database :)
declare variable $csr_proc:stored_query_dir := "../resources/stored_query_definitions";
declare variable $csr_proc:stored_updating_query_dir := "../resources/stored_updating_query_definitions";

declare variable $csr_proc:stored_functions :=
if (file:is-dir($csr_proc:stored_query_dir)) then
  for $file in file:list($csr_proc:stored_query_dir,boolean('false'),"*.xml")
  return doc(concat($csr_proc:stored_query_dir,'/',$file))/csd:careServicesFunction
else ();


declare variable $csr_proc:stored_updating_functions :=
if (file:is-dir($csr_proc:stored_updating_query_dir)) then
  for $file in file:list($csr_proc:stored_updating_query_dir,boolean('false'),"*.xml")
  return doc(concat($csr_proc:stored_updating_query_dir,'/',$file))/csd:careServicesFunction
else ();



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

let $expr :=string($expression)
return if ($expr) then
  let $result := xquery:evaluate($expr,map{"":=$doc})
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
let $uuid := $function/@uuid
let $definition := $csr_proc:stored_functions[@uuid = $uuid][1]/csd:definition
let $content_type := csr_proc:lookup_stored_content_type($function/@uuid)
return if (exists($definition)) then
  let $result := 
    xquery:evaluate($definition,map{'':=$doc,'careServicesRequest':=$function/requestParams})  
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





declare updating function csr_proc:process_updating_CSR($careServicesRequest, $doc) 
{
(:not allowing ad-hoc updates:)
let $function :=$careServicesRequest//csd:function
let $uuid := $function/@uuid
let $definition := $csr_proc:stored_updating_functions[@uuid = $uuid][1]/csd:definition
return 
  if (exists($definition)) then
    (:Assumes called method handles db:output.  Nothing is encapsulated :)
    db:output(
      xquery:evaluate($definition,map{'':=$doc,'careServicesRequest':=$function/requestParams})
       )
  else 
    db:output(
    <rest:response>
      <http:response status="404" message="No registered updating function with UUID='{$function/@uuid}.'">
	<http:header name="Content-Language" value="en"/>
	<http:header name="Content-Type" value="text/html; charset=utf-8"/>
      </http:response>
    </rest:response>
       )
};




declare function csr_proc:lookup_stored_content_type($uuid) 
{
  string(($csr_proc:stored_functions[@uuid = $uuid]/@content-type, $csr_proc:stored_updating_functions[@uuid = $uuid]/@content-type  , "text/xml")[1])
};


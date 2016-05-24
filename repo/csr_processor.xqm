(:~
: This is the Care Services Discovery RESTful document processor
: @version 1.0
: @see https://github.com/openhie/openinfoman
:
:)
module namespace csr_proc = "https://github.com/openhie/openinfoman/csr_proc";

import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";


declare   namespace   csd = "urn:ihe:iti:csd:2013";
declare namespace xquery = "http://basex.org/modules/xquery";


(:this should proabably be moved to the database :)
declare variable $csr_proc:stored_query_dir := concat(file:current-dir() , "../resources/stored_query_definitions");
declare variable $csr_proc:stored_updating_query_dir := concat(file:current-dir() , "../resources/stored_updating_query_definitions");


declare variable $csr_proc:stored_functions_doc := 'stored_functions.xml';
declare variable $csr_proc:stored_updating_functions_doc := 'stored_updating_functions.xml';


declare function csr_proc:stored_functions() {
 db:open($csd_webconf:db,$csr_proc:stored_functions_doc)/careServicesFunctions/csd:careServicesFunction
};

declare function csr_proc:stored_updating_functions() {
 db:open($csd_webconf:db,$csr_proc:stored_updating_functions_doc)/careServicesFunctions/csd:careServicesFunction
};


declare updating function csr_proc:init() {
  (
    if (not (db:is-xml($csd_webconf:db,$csr_proc:stored_updating_functions_doc))) then
      db:add($csd_webconf:db, <careServicesFunctions/>,$csr_proc:stored_updating_functions_doc)
    else 
      ()
      ,
    if (not (db:is-xml($csd_webconf:db,$csr_proc:stored_functions_doc))) then
      db:add($csd_webconf:db, <careServicesFunctions/>,$csr_proc:stored_functions_doc)
    else 
      ()
  )
};

declare updating function csr_proc:clear_stored_functions() { 
  (
    db:delete($csd_webconf:db,$csr_proc:stored_functions_doc)
    ,db:delete($csd_webconf:db,$csr_proc:stored_updating_functions_doc)
    ,csr_proc:init()
    )
      
};

declare updating function csr_proc:delete_stored_function($urn) {
  let $stored_updating_functions := db:open($csd_webconf:db,$csr_proc:stored_updating_functions_doc)/careServicesFunctions/*
  let $stored_functions := db:open($csd_webconf:db,$csr_proc:stored_functions_doc)/careServicesFunctions/*
  let $functions := ($stored_functions,$stored_updating_functions)
    
  let $old := $functions[@urn = $urn]
  return if ($old) then delete node $old else ()
    
};

declare updating function csr_proc:load_stored_updating_function($func) {
  let $stored_updating_functions := db:open($csd_webconf:db,$csr_proc:stored_updating_functions_doc)/careServicesFunctions
  let $urn := $func/@urn
  let $old := $stored_updating_functions/csd:careServicesFunction[@urn = $urn]
  return 
    if (exists($urn)) then	  
      if (exists($old)) 
	then
	(delete node $old,
	insert node $func into $stored_updating_functions
	)
      else
	insert node $func into $stored_updating_functions
  else ()
};

declare updating function csr_proc:load_stored_function($func) {
  let $stored_functions := db:open($csd_webconf:db,$csr_proc:stored_functions_doc)/careServicesFunctions
  let $urn := $func/@urn
  let $old := $stored_functions/csd:careServicesFunction[@urn = $urn]
  return 
    if (exists($urn) and exists($stored_functions)) then	  
      if (exists($old)) 
	then
	(delete node $old,
	insert node $func into $stored_functions
	)
      else
	insert node $func into $stored_functions
    else ()
};
	  


declare function csr_proc:process_CSR($careServicesRequest, $doc_name,$base_url) 
{
csr_proc:process_CSR($careServicesRequest, $doc_name, $base_url,map:merge(())) 
};

declare function csr_proc:process_CSR($careServicesRequest, $doc_name,$base_url,$bindings as map(*)) 
{
let $function :=
  if (exists($careServicesRequest/csd:function))
  then $careServicesRequest/csd:function (:backwards compatability for CP-926 :)
  else $careServicesRequest 


return if (exists($function)) 
then
  let $urn := string($function/@urn)
  return
    let $csr :=
    <csd:careServicesRequest  urn="{$urn}" resource='{$doc_name}' base_url='{$base_url}'>
      {$function/*}
    </csd:careServicesRequest>
    let $csr_bindings :=  map{'careServicesRequest':$csr}
    let $all_bindings :=  map:merge(($csr_bindings, $bindings))
    return csr_proc:process_CSR_stored($csr,$all_bindings) 
else 
 (:
  <rest:response>
    <http:response status="400" message="Invalid care services request.">
      <http:header name="Content-Language" value="en"/>
      <http:header name="Content-Type" value="text/html; charset=utf-8"/>
    </http:response>
  </rest:response>
  :)
  $careServicesRequest


};


declare function csr_proc:process_CSR_adhoc($expression,$doc_name) {
   csr_proc:process_CSR_adhoc($expression,$doc_name,map:merge(()))
};

declare function csr_proc:process_CSR_adhoc($expression,$doc_name,$bindings as map(*)) 
{

let $doc :=  csd_dm:open_document($doc_name)

let $expr :=string($expression)
return if ($expr) then
  let $result := xquery:eval($expr,map{"":$doc},$bindings)
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



declare function csr_proc:process_CSR_stored($careServicesRequest) 
{
  csr_proc:process_CSR_stored($careServicesRequest,map:merge(())) 
};

declare function csr_proc:process_CSR_stored($careServicesRequest,$bindings as map(*)) 
{
  let $function :=
    if ( exists($careServicesRequest/csd:function))
    then $careServicesRequest/csd:function (: backwards compatability for CP-926 :)
    else $careServicesRequest
  let $stored_functions := csr_proc:stored_functions()
  let $urn := string($function/@urn)
  let $definition := ($stored_functions[@urn = $urn])[1]/csd:definition/text()
  let $content_type := csr_proc:lookup_stored_content_type($function/@urn)
  let $doc_name := string($function/@resource)
  let $doc :=  csd_dm:open_document($doc_name)

  let $results0 := csr_proc:process_CSR_stored_results($doc,$careServicesRequest,$bindings)

  return 
    if (exists($definition)) 
    then
     (
       <rest:response>
	 <http:response status="200" >
	   <http:header name="Content-Type" value="{$content_type}"/>
	 </http:response>
       </rest:response>
       ,
       $results0
    )
    else
      <rest:response>
	<http:response status="404" message="No registered function with URN='{$function/@urn}'.">
	  <http:header name="Content-Language" value="en"/>
	  <http:header name="Content-Type" value="text/html; charset=utf-8"/>
	</http:response>
      </rest:response>
};

declare function csr_proc:wrap_result($result,$content-type) {
 <csd:careServicesResponse content-type="{$content-type}"><csd:result>{$result}</csd:result></csd:careServicesResponse>
};


declare function csr_proc:process_CSR_stored_results($doc,$careServicesRequest) 
{
  csr_proc:process_CSR_stored_results($doc,$careServicesRequest,map:merge(())) 
};

declare function csr_proc:process_CSR_stored_results($doc,$careServicesRequest,$bindings as map(*)) 
{
let $function :=
  if (exists($careServicesRequest/csd:function ))
  then $careServicesRequest/csd:function
  else $careServicesRequest

let $urn := $function/@urn

let $doc_name :=  string($function/@resource)
let $base_url :=  string($function/@base_url)


let $stored_functions := csr_proc:stored_functions()
let $definition := ($stored_functions[@urn = $urn])[1]/csd:definition/text()

let $options := csr_proc:lookup_stored_options($function/@urn)

let $csr := 
 <csd:careServicesRequest resource='{$doc_name}' function='{$urn}' base_url='{$base_url}'>
   { $function/*}
 </csd:careServicesRequest>


let $csr_bindings :=  map{'':$doc,'careServicesRequest':$csr}
let $all_bindings :=  map:merge(($csr_bindings, $bindings))

return if (exists($definition)) then
  xquery:eval($definition,$all_bindings,$options)
else ()
};



declare function csr_proc:create_adhoc_doc($adhoc_query,$content_type) {
  let $content := if ($content_type) then $content_type else "application/xml" 
  return
  <csd:careServicesRequest urn="urn:ihe:iti:csd:2014:adhoc">
    <csd:adhoc content-type='{$content}'>
      {$adhoc_query}
    </csd:adhoc>
  </csd:careServicesRequest>



};



declare function csr_proc:get_function_definition($urn) {
  csr_proc:stored_functions()[@urn = $urn][1]
};


declare function csr_proc:get_updating_function_definition($urn) {
  csr_proc:stored_updating_functions()[@urn = $urn][1]
};


declare function csr_proc:get_any_function_definition($urn) {
  (csr_proc:stored_updating_functions()[@urn = $urn] , csr_proc:stored_functions()[@urn = $urn])[1]
};




declare updating function csr_proc:process_updating_CSR($function,$doc_name,$base_url) 
{
  csr_proc:process_updating_CSR($function,$doc_name,$base_url,map:merge(())) 
};


declare updating function csr_proc:process_updating_CSR_results($function) 
{
  csr_proc:process_updating_CSR_results($function,map:merge(())) 
};


declare updating function csr_proc:process_updating_CSR_results($careServicesRequest, $bindings as map(*)) {
let $function :=
  if (exists($careServicesRequest/csd:function))
  then $careServicesRequest/csd:function
  else $careServicesRequest
let $doc_name := string($function/@resource)
let $base_url := string($function/@base_url)
let $doc := csd_dm:open_document($doc_name)
let $urn := $function/@urn
let $stored_updating_functions := csr_proc:stored_updating_functions()
let $definition := $stored_updating_functions[@urn = $urn][1]/csd:definition/text()
let $content_type := csr_proc:lookup_stored_content_type($function/@urn)
let $csr := 
  <csd:careServicesRequest resource='{$doc_name}' function='{$urn}' base_url='{$base_url}'>
    {$function/*}
  </csd:careServicesRequest>

let $csr_bindings :=  map{'':$doc,'careServicesRequest':$csr}
let $all_bindings :=  map:merge(($csr_bindings, $bindings))

let $options := csr_proc:lookup_stored_options($function/@urn)

return if (exists($definition)) then
  (
  xquery:update($definition,$all_bindings,$options)
  )
else  ()

};



declare updating function csr_proc:process_updating_CSR_stored_results($doc,$careServicesRequest) 
{
  csr_proc:process_updating_CSR_stored_results($doc,$careServicesRequest,map:merge(())) 
};

declare updating function csr_proc:process_updating_CSR_stored_results($doc,$careServicesRequest,$bindings as map(*)) 
{
let $stored_updating_functions := csr_proc:stored_updating_functions()

let $csr_bindings :=  map{'':$doc,'careServicesRequest':$careServicesRequest}
let $all_bindings :=  map:merge(($csr_bindings, $bindings))
let $urn := $careServicesRequest/@urn
let $options := csr_proc:lookup_stored_options($urn)
let $definition := $stored_updating_functions[@urn = $urn][1]/csd:definition/text()
let $out := serialize($careServicesRequest)
return if (exists($definition)) then
  xquery:update($definition,$all_bindings,$options)
else 
    db:output(
    <rest:response>
      <http:response status="404" message="No registered updating function with URN='{$urn}'">
	<http:header name="Content-Language" value="en"/>
	<http:header name="Content-Type" value="text/html; charset=utf-8"/>
      </http:response>
    </rest:response>
       )
};

 


declare updating function csr_proc:process_updating_CSR($careServicesRequest, $doc_name, $base_url,$bindings as map(*)) 
{

let $doc := csd_dm:open_document($doc_name)
let $function := 
  if (exists($careServicesRequest/csd:function))
  then $careServicesRequest/csd:function (: CP -926 backward compat :)
  else $careServicesRequest
let $urn := string($function/@urn)
let $content_type := csr_proc:lookup_stored_content_type($function/@urn)
let $csr := 
  <csd:careServicesRequest resource="{$doc_name}" function="{$urn}" base_url="{$base_url}"> 
    { $function }
  </csd:careServicesRequest>

let $csr_bindings :=  map{'':$doc,'careServicesRequest':$csr}
let $all_bindings :=  map:merge(($csr_bindings, $bindings))


return csr_proc:process_updating_CSR_stored_results($doc,$csr,$all_bindings)
};


declare function csr_proc:lookup_stored_options($urn)
{
  let $stored_updating_functions := csr_proc:stored_updating_functions()
  let $stored_functions := csr_proc:stored_functions()
  let $func := ($stored_functions[@urn = $urn], $stored_updating_functions[@urn = $urn])[1]
   return  ($func/csd:extension[@urn='urn:openhie.org:openinfoman:csr_processor' and  @type='xquery:options']/xquery:options)[1]
     (: See: http://docs.basex.org/wiki/XQuery_Module :)
};

declare function csr_proc:lookup_stored_content_type($urn) 
{
  let $stored_updating_functions := csr_proc:stored_updating_functions()
  let $stored_functions := csr_proc:stored_functions()
  return string(($stored_functions[@urn = $urn]/@content-type, $stored_updating_functions[@urn = $urn]/@content-type  , "text/xml")[1])
};




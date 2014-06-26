(:~
: This is the Care Services Discovery RESTful document processor
: @version 1.0
: @see https://github.com/his-interop/openinfoman
:
:)
module namespace csr_proc = "https://github.com/his-interop/openinfoman/csr_proc";

import module namespace file = "http://expath.org/ns/file";
import module namespace csd_dm = "https://github.com/his-interop/openinfoman/csd_dm";

declare   namespace   csd = "urn:ihe:iti:csd:2013";
declare namespace xquery = "http://basex.org/modules/xquery";


(:this should proabably be moved to the database :)
declare variable $csr_proc:stored_query_dir := concat(file:current-dir() , "../resources/stored_query_definitions");
declare variable $csr_proc:stored_updating_query_dir := concat(file:current-dir() , "../resources/stored_updating_query_definitions");


declare variable $csr_proc:stored_functions_doc := 'stored_functions.xml';
declare variable $csr_proc:stored_updating_functions_doc := 'stored_updating_functions.xml';


declare function csr_proc:stored_functions($db) {
 db:open($db,$csr_proc:stored_functions_doc)/careServicesFunctions/csd:careServicesFunction
};

declare function csr_proc:stored_updating_functions($db) {
 db:open($db,$csr_proc:stored_updating_functions_doc)/careServicesFunctions/csd:careServicesFunction
};


declare updating function csr_proc:init($db) {
  (
    if (not (db:is-xml($db,$csr_proc:stored_updating_functions_doc))) then
      db:add($db, <careServicesFunctions/>,$csr_proc:stored_updating_functions_doc)
    else 
      ()
      ,
    if (not (db:is-xml($db,$csr_proc:stored_functions_doc))) then
      db:add($db, <careServicesFunctions/>,$csr_proc:stored_functions_doc)
    else 
      ()
  )
};

declare updating function csr_proc:clear_stored_functions($db) { 
  (
    db:delete($db,$csr_proc:stored_functions_doc)
    ,db:delete($db,$csr_proc:stored_updating_functions_doc)
    ,csr_proc:init($db)
    )
      
};

declare updating function csr_proc:load_functions_from_files($db) {
  (
    if (file:is-dir($csr_proc:stored_query_dir)) then
      for $file in file:list($csr_proc:stored_query_dir,boolean('false'),"*.xml")
      let $func := doc(concat($csr_proc:stored_query_dir,'/',$file))/csd:careServicesFunction
      return if (exists($func)) then csr_proc:load_stored_function($db,$func) else ()
    else()
      ,
    if (file:is-dir($csr_proc:stored_updating_query_dir)) then
      for $file in file:list($csr_proc:stored_updating_query_dir,boolean('false'),"*.xml")
      let $func := doc(concat($csr_proc:stored_updating_query_dir,'/',$file))/csd:careServicesFunction
      return if (exists($func)) then csr_proc:load_stored_updating_function($db,$func) else ()
    else ()
  )
};

declare updating function csr_proc:delete_stored_function($db,$uuid) {
  let $stored_updating_functions := db:open($db,$csr_proc:stored_updating_functions_doc)/careServicesFunctions/*
  let $stored_functions := db:open($db,$csr_proc:stored_functions_doc)/careServicesFunctions/*
  let $functions := ($stored_functions,$stored_updating_functions)
    
  let $old := $functions[@uuid = $uuid]
  return if ($old) then delete node $old else ()
    
};

declare updating function csr_proc:load_stored_updating_function($db,$func) {
  let $stored_updating_functions := db:open($db,$csr_proc:stored_updating_functions_doc)/careServicesFunctions
  let $uuid := $func/@uuid
  let $old := $stored_updating_functions/csd:careServicesFunction[@uuid = $uuid]
  return 
    if (exists($uuid)) then	  
      if (exists($old)) 
	then
	(delete node $old,
	insert node $func into $stored_updating_functions
	)
      else
	insert node $func into $stored_updating_functions
  else ()
};

declare updating function csr_proc:load_stored_function($db,$func) {
  let $stored_functions := db:open($db,$csr_proc:stored_functions_doc)/careServicesFunctions
  let $uuid := $func/@uuid
  let $old := $stored_functions/csd:careServicesFunction[@uuid = $uuid]
  return 
    if (exists($uuid) and exists($stored_functions)) then	  
      if (exists($old)) 
	then
	(delete node $old,
	insert node $func into $stored_functions
	)
      else
	insert node $func into $stored_functions
    else ()
};
	  


declare function csr_proc:process_CSR($db,$careServicesRequest, $doc_name,$base_url) 
{
csr_proc:process_CSR($db,$careServicesRequest, $doc_name, $base_url,map:new(())) 
};

declare function csr_proc:process_CSR($db,$careServicesRequest, $doc_name,$base_url,$bindings as map(*)) 
{
let $func :=$careServicesRequest/csd:function
let $adhoc :=$careServicesRequest/csd:expression
return if (exists($func)) 
then
  csr_proc:process_CSR_stored($db,$func,$doc_name,$base_url,$bindings) 
else if (exists($adhoc))
then
  csr_proc:process_CSR_adhoc($db,$adhoc,$doc_name,$bindings) 
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


declare function csr_proc:process_CSR_adhoc($db,$expression,$doc_name) {
   csr_proc:process_CSR_adhoc($expression,$doc_name,map:new(()))
};

declare function csr_proc:process_CSR_adhoc($db,$expression,$doc_name,$bindings as map(*)) 
{
let $doc := csd_dm:open_document($db,$doc_name)
let $expr :=string($expression)
return if ($expr) then
  let $result := xquery:eval($expr,map{"":=$doc},$bindings)
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



declare function csr_proc:process_CSR_stored($db,$function,$doc_name,$base_url) 
{
  csr_proc:process_CSR_stored($db,$function,$doc_name,$base_url,map:new()) 
};

declare function csr_proc:process_CSR_stored($db,$function,$doc_name,$base_url,$bindings as map(*)) 
{
let $doc := csd_dm:open_document($db,$doc_name)
let $uuid := $function/@uuid
let $stored_functions := csr_proc:stored_functions($db)
let $definition := $stored_functions[@uuid = $uuid][1]/csd:definition/text()
let $content_type := csr_proc:lookup_stored_content_type($db,$function/@uuid)
let $options := csr_proc:lookup_stored_options($db,$function/@uuid)
let $requestParams := <csd:requestParams resource='{$doc_name}' function='{$uuid}' base_url='{$base_url}'>
  {
    if ($function/csd:requestParams) then $function/csd:requestParams/*
    else $function/requestParams/*
  }
</csd:requestParams>

let $csr_bindings :=  map{'':=$doc,'careServicesRequest':=$requestParams}
let $all_bindings :=  map:new(($csr_bindings, $bindings))

let $result0 := 
  if (exists($definition)) then
    xquery:eval($definition,$all_bindings,$options)      
  else
    ()
let $result1:= 
  if ($function/@encapsulated) then
    csr_proc:wrap_result($result0,$content_type)
  else $result0
return if ($result0) then
  (
  <rest:response>
    <http:response status="200" >
      <http:header name="Content-Type" value="{$content_type}"/>
    </http:response>
  </rest:response>
  ,
  $result1
  )
else
  <rest:response>
    <http:response status="404" message="No registered function with UUID='{$function/@uuid}'.">
      <http:header name="Content-Language" value="en"/>
      <http:header name="Content-Type" value="text/html; charset=utf-8"/>
    </http:response>
  </rest:response>
    
};

declare function csr_proc:wrap_result($result,$content-type) {
 <csd:careServicesResponse content-type="{$content-type}"><csd:result>{$result}</csd:result></csd:careServicesResponse>
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


declare function csr_proc:get_function_definition($db,$uuid) {
  csr_proc:stored_functions($db)[@uuid = $uuid][1]
};

declare function csr_proc:get_updating_function_definition($db,$uuid) {
  csr_proc:stored_updating_functions($db)[@uuid = $uuid][1]
};




declare updating function csr_proc:process_updating_CSR($db,$function,$doc_name,$base_url) 
{
  csr_proc:process_updating_CSR($db,$function,$doc_name,$base_url,map:new(())) 
};


declare updating function csr_proc:process_updating_CSR($db,$careServicesRequest, $doc_name, $base_url,$bindings as map(*)) 
{
(:not allowing ad-hoc updates:) 
let $doc := csd_dm:open_document($db,$doc_name)
let $function :=$careServicesRequest//csd:function
let $uuid := $function/@uuid
let $stored_updating_functions := csr_proc:stored_updating_functions($db)
let $definition := $stored_updating_functions[@uuid = $uuid][1]/csd:definition/text()
let $content_type := csr_proc:lookup_stored_content_type($db,$function/@uuid)
let $requestParams := <csd:requestParams resource='{$doc_name}' function='{$uuid}' base_url='{$base_url}'>
  {
    if ($function/csd:requestParams) then $function/csd:requestParams/*
    else $function/requestParams/*
  }
</csd:requestParams>

let $csr_bindings :=  map{'':=$doc,'careServicesRequest':=$requestParams}
let $all_bindings :=  map:new(($csr_bindings, $bindings))

let $options := csr_proc:lookup_stored_options($db,$function/@uuid)

return if (exists($definition)) then
  xquery:update($definition,$all_bindings,$options)
else 
    db:output(
    <rest:response>
      <http:response status="404" message="No registered updating function with UUID='{$function/@uuid} ">
	<http:header name="Content-Language" value="en"/>
	<http:header name="Content-Type" value="text/html; charset=utf-8"/>
      </http:response>
    </rest:response>
       )
};


declare function csr_proc:lookup_stored_options($db,$uuid)
{
  let $stored_updating_functions := csr_proc:stored_updating_functions($db)
  let $stored_functions := csr_proc:stored_functions($db)
  let $func := ($stored_functions[@uuid = $uuid], $stored_updating_functions[@uuid = $uuid])[1]
   return  ($func/csd:extension[@urn='urn:openhie.org:openinfoman:csr_processor' and  @type='xquery:options']/xquery:options)[1]
     (: See: http://docs.basex.org/wiki/XQuery_Module :)
};

declare function csr_proc:lookup_stored_content_type($db,$uuid) 
{
  let $stored_updating_functions := csr_proc:stored_updating_functions($db)
  let $stored_functions := csr_proc:stored_functions($db)
  return string(($stored_functions[@uuid = $uuid]/@content-type, $stored_updating_functions[@uuid = $uuid]/@content-type  , "text/xml")[1])
};




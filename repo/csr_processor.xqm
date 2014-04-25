(:~
: This is the Care Services Discovery RESTful document processor
: @version 1.0
: @see https://github.com/his-interop/openinfoman
:
:)
module namespace csr_proc = "https://github.com/his-interop/openinfoman/csr_proc";


(:import module namespace csd_bsq = "https://github.com/his-interop/openinfoman/csd_bsq" at "csd_base_stored_queries.xqm";
import module namespace csd_hwr = "https://github.com/his-interop/openinfoman-hwr/csd_hwr" at "csd_health_worker_registry.xqm";
import module namespace csd_hwru = "https://github.com/his-interop/openinfoman-hwr/csd_hwru" at "csd_health_worker_registry_updating.xqm";
:)

declare   namespace   csd = "urn:ihe:iti:csd:2013";
declare default element  namespace   "urn:ihe:iti:csd:2013";


(:this should proabably be moved to the database :)
declare variable $csr_proc:stored_query_dir := "../resources/stored_query_definitions";
declare variable $csr_proc:stored_updating_query_dir := "../resources/stored_updating_query_definitions";


declare variable $csr_proc:stored_functions_doc := 'stored_functions.xml';
declare variable $csr_proc:stored_updating_functions_doc := 'stored_updating_functions.xml';


declare function csr_proc:stored_functions($db) {
 db:open($db,$csr_proc:stored_functions_doc)/careServicesFunctions/careServicesFunction
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

declare updating function csr_proc:load_functions_from_files($db) {
  (
    if (file:is-dir($csr_proc:stored_query_dir)) then
      for $file in file:list($csr_proc:stored_query_dir,boolean('false'),"*.xml")
      let $func := doc(concat($csr_proc:stored_query_dir,'/',$file))/careServicesFunction
      return if (exists($func)) then csr_proc:load_stored_function($db,$func) else ()
    else()
      ,
    if (file:is-dir($csr_proc:stored_updating_query_dir)) then
      for $file in file:list($csr_proc:stored_updating_query_dir,boolean('false'),"*.xml")
      let $func := doc(concat($csr_proc:stored_updating_query_dir,'/',$file))/careServicesFunction
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
  let $old := $stored_updating_functions/careServicesFunction[@uuid = $uuid]
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
  let $old := $stored_functions/careServicesFunction[@uuid = $uuid]
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
	  


declare function csr_proc:process_CSR($db,$careServicesRequest, $doc) 
{
let $func :=$careServicesRequest/function
let $adhoc :=$careServicesRequest/expression
return if (exists($func)) 
then
  csr_proc:process_CSR_stored($db,$func,$doc) 
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



declare function csr_proc:process_CSR_stored($db,$function,$doc) 
{
let $uuid := $function/@uuid
let $stored_functions := csr_proc:stored_functions($db)
let $definition := $stored_functions[@uuid = $uuid][1]/definition/text()
let $method_name := $stored_functions[@uuid = $uuid][1]/definition/@method
let $method :=  if ($method_name) then function-lookup( xs:QName($method_name), 2) else ()
let $content_type := csr_proc:lookup_stored_content_type($db,$function/@uuid)
let $result0 := 
  if (exists($method)) then
    $method($function/requestParams,$doc)
  else
    if (exists($definition)) then
      xquery:evaluate($definition,map{'':=$doc,'careServicesRequest':=$function/requestParams})      
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





declare updating function csr_proc:process_updating_CSR($db,$careServicesRequest, $doc) 
{
(:not allowing ad-hoc updates:) 
let $function :=$careServicesRequest//csd:function
let $uuid := $function/@uuid
let $stored_updating_functions := csr_proc:stored_updating_functions($db)
let $method_name := $stored_updating_functions[@uuid = $uuid][1]/csd:definition/@method
let $method :=  if ($method_name) then function-lookup( xs:QName($method_name), 2) else ()
let $content_type := csr_proc:lookup_stored_content_type($db,$function/@uuid)
return  if (exists($method)) then
    db:output(
      $method($function/requestParams,$doc)
    )
  else
    db:output(
    <rest:response>
      <http:response status="404" message="No registered updating function with UUID='{$function/@uuid} or method name '{$method_name}'">
	<http:header name="Content-Language" value="en"/>
	<http:header name="Content-Type" value="text/html; charset=utf-8"/>
      </http:response>
    </rest:response>
       )
};




declare function csr_proc:lookup_stored_content_type($db,$uuid) 
{
  let $stored_updating_functions := csr_proc:stored_updating_functions($db)
  let $stored_functions := csr_proc:stored_functions($db)
  return string(($stored_functions[@uuid = $uuid]/@content-type, $stored_updating_functions[@uuid = $uuid]/@content-type  , "text/xml")[1])
};




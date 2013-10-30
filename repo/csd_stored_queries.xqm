(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/his-interop/openinfoman
:
:)
module namespace csd_sq = "https://github.com/his-interop/openinfoman/csd_sq";

import module namespace csd_bsq =  "https://github.com/his-interop/openinfoman/csd_bsq" at "csd_base_stored_queries.xqm";

declare variable $csd_sq:stored_functions :=
<storedFunctionLibrary>
   <function uuid='4e8bbeb9-f5f5-11e2-b778-0800200c9a66' 
   	     method='csd_bsq:provider_search'	    
   	     namespace='csd_bsq'
	     namespaceURI='https://github.com/his-interop/openinfoman/csd_bsq'
	     namespaceLocation = "csd_base_stored_queries.xqm"
 	     content-type='text/xml; charset=utf-8'      
	     />
   <function uuid='dc6aedf0-f609-11e2-b778-0800200c9a66'
   	     method='csd_bsq:organization_search'	    
 	     content-type='text/xml; charset=utf-8'      
	     />
   <function uuid='e3d8ecd0-f605-11e2-b778-0800200c9a66'
   	     method='csd_bsq:service_search'	    
 	     content-type='text/xml; charset=utf-8'      
	     />
   <function uuid='c7640530-f600-11e2-b778-0800200c9a66'
   	     method='csd_bsq:facility_search'	    
 	     content-type='text/xml; charset=utf-8'      
	     />
</storedFunctionLibrary>
;

declare function csd_sq:get_stored_query($uuid) {
  let $method_name := csd_sq:lookup_stored_method($uuid) 
  return if ($method_name) then function-lookup( xs:QName($method_name), 2) else ()
};


declare function csd_sq:has_stored_query($uuid) {
   if (exists(csd_sq:get_stored_query($uuid))) then true() else false()
};

declare function csd_sq:execute_stored_query($doc,$uuid,$requestParams) {
  let $method := csd_sq:get_stored_query($uuid)
  return if (exists($method )) 
  then
     $method($requestParams,$doc)   
  else
    ()

};

declare function csd_sq:lookup_stored_method($uuid) 
{
  $csd_sq:stored_functions/function[@uuid = $uuid]/@method
};


declare function csd_sq:lookup_stored_content_type($uuid) 
{
   ($csd_sq:stored_functions/function[@uuid = $uuid]/@content-type , "text/xml")[1]
};



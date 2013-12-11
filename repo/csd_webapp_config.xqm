(:~
: This is a module conttaining configuration options for the openinfoman webap
: @version 1.0
: @see https://github.com/his-interop/openinfoman @see http://ihe.net
:
:)

module namespace csd_webconf = "https://github.com/his-interop/openinfoman/csd_webconf";
import module namespace request = "http://exquery.org/ns/request";



(:Import statements for stored queries.  Each module needs to be imported:)
import module namespace csd_bsq =  "https://github.com/his-interop/openinfoman/csd_bsq" at "csd_base_stored_queries.xqm";
(: import module namespace csd_prsq = "https://github.com/his-interop/openinfoman-pr/csd_prsq" at  "csd_provider_registry_stored_queries.xqm"; :)


(:Database we are working on:)
declare variable $csd_webconf:db :=  'provider_directory';

(:BASE URL for openinforman. Overwrite this if you are proxying the openinfoman.   :)
declare variable $csd_webconf:baseurl :=  concat(request:scheme(),"://",request:hostname(),":",request:port(), "/"); 


declare variable $csd_webconf:stored_functions :=
<storedFunctionLibrary>
   <function uuid='4e8bbeb9-f5f5-11e2-b778-0800200c9a66' 
   	     method='csd_bsq:provider_search'	    
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
    <function uuid='fcbab300-6270-11e3-bd76-0002a5d5c51b'
              method='csd_prsq:oid_search_by_id'
 	     content-type='text/xml; charset=utf-8'      
	     />
</storedFunctionLibrary>
;



declare function csd_webconf:get_stored_query($uuid) {
  let $method_name := csd_webconf:lookup_stored_method($uuid) 
  return if ($method_name) then function-lookup( xs:QName($method_name), 2) else (false())

};


declare function csd_webconf:has_stored_query($uuid) {
  let $sq := csd_webconf:get_stored_query($uuid)
  return if (exists($sq))  then true() else false()
};

declare function csd_webconf:execute_stored_query($doc,$uuid,$requestParams) {
  let $method := csd_webconf:get_stored_query($uuid)
  return if (exists($method )) 
  then
     $method($requestParams,$doc)   
  else
    ()

};

declare function csd_webconf:lookup_stored_method($uuid) 
{
  $csd_webconf:stored_functions/function[@uuid = $uuid]/@method
};


declare function csd_webconf:lookup_stored_content_type($uuid) 
{
   ($csd_webconf:stored_functions/function[@uuid = $uuid]/@content-type , "text/xml")[1]
};



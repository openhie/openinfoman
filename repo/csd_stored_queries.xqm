(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/his-interop/openinfoman
:
:)
module namespace csd_sq = "https://github.com/his-interop/openinfoman/csd_sq";
import module namespace csd_bsq = "https://github.com/his-interop/openinfoman/csd_nsq" at "csd_bsq.xqm";

declare variable $csd:stored_functions :=
<storedFunctions>
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
</storedFunctions>


declare function csd_sq:lookup_stored_method($uuid) 
{
return $csd:stored_functions/function[@uuid = $uuid]/@method
};


declare function csd_sq:lookup_stored_content_type($uuid) 
{
return $csd:stored_functions/function[@uuid = $uuid]/@content-type
};



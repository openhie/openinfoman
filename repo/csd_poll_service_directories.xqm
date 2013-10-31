(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/his-interop/openinfoman
:
:)
module namespace csd_psd = "https://github.com/his-interop/openinfoman/csd_psd";
import module namespace csd_qus =  "https://github.com/his-interop/openinfoman/csd_qus" at "csd_query_updated_services.xqm";

declare variable $csd_psd:services_library :=
<serviceDirectoryLibrary>
   <serviceDirectory 
        name='simple_provider'
        doc='services_directories/providers.xml'
        url='http://csd.ihris.org:8983/CSD/getUpdatedServices'
	last_mtime='2013-10-01T14:53:00+00:00'/>	
</serviceDirectoryLibrary>
;


declare function csd_psd:get_service_directory_url($name) {
  $csd_psd:services_library//serviceDirectory[@name=$name]/@url
};

declare function csd_psd:get_service_directory_mtime($name) {
  $csd_psd:services_library//serviceDirectory[@name=$name]/@last_mtime
};

declare function csd_psd:poll_service_directory($name) 
{
  let $url := csd_psd:get_service_directory_url($name)    
  let $last_mtime := csd_psd:get_service_directory_mtime($name)
  let $request := 
    <http:request 
      href='{$url}'  
      method='post' >
      <http:body media-type='text/html; charset=utf-8'>
      {csd_qus:create_last_update_request($last_mtime)}    
      </http:body>
    </http:request>

  let $response := http:send-request($request)    
  return if ($response[2]/http:response/@status = "200") 
  then
    $response[2]    
  else
    ()

};



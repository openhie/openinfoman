(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/his-interop/openinfoman
:
:)
module namespace csd_psd = "https://github.com/his-interop/openinfoman/csd_psd";
import module namespace csd_qus =  "https://github.com/his-interop/openinfoman/csd_qus" at "csd_query_updated_services.xqm";
declare namespace http = "http://expath.org/ns/http-client" ;

declare variable $csd_psd:services_library :=
<serviceDirectoryLibrary>
   <serviceDirectory 
        name='simple_provider'
        doc='services_directories/providers.xml'
        url='http://csd.ihris.org:8984/CSD/getUpdatedServices'
	last_mtime='2013-10-01T14:53:00+00:00'/>	

</serviceDirectoryLibrary>
;


declare function csd_psd:get_services() { 
  $csd_psd:services_library//serviceDirectory/text{@name}
};

declare function csd_psd:get_service_directory_url($name) {
 text{ $csd_psd:services_library//serviceDirectory[@name=$name]/@url}
};

declare function csd_psd:get_service_directory_mtime($name) {
  text{$csd_psd:services_library//serviceDirectory[@name=$name]/@last_mtime}
};

declare function csd_psd:get_service_directory_soap_request($name) 
{

 let $last_mtime := csd_psd:get_service_directory_mtime($name)
 return csd_qus:create_last_update_request($last_mtime)

};

declare function csd_psd:poll_service_directory($name) 
{
  let $url := csd_psd:get_service_directory_url($name)    
  let $request := <http:request 
      href='{$url}'  
      mime-type="application/x-www-form-urlencoded"
      method='post' >
      <http:body media-type='application/xml; charset=utf-8'>
      {csd_psd:get_service_directory_soap_request($name)}
      </http:body>
    </http:request>

  let $response := http:send-request($request)   
  let $status := text{$response[1]/@status}
  return if ($status = "200") 
  then
    $response[2]    
  else
    ($status, $url,$request)

};



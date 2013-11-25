(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/his-interop/openinfoman
:
:)
module namespace csd_psd = "https://github.com/his-interop/openinfoman/csd_psd";
import module namespace csd_qus =  "https://github.com/his-interop/openinfoman/csd_qus" at "csd_query_updated_services.xqm";
import module namespace request = "http://exquery.org/ns/request";
declare namespace http = "http://expath.org/ns/http-client" ;
declare namespace soap = "http://www.w3.org/2003/05/soap-envelope";
declare namespace csd = "urn:ihe:iti:csd:2013";

declare variable $csd_psd:services_library :=
<serviceDirectoryLibrary>


   <serviceDirectory 
        name='localhost'
	url='{request:scheme()}://localhost:{request:port()}/CSD/getUpdatedServices'
	/>
   <serviceDirectory 
        name='rhea_simple_provider'
	url='http://rhea-pr.ihris.org/providerregistry/getUpdatedServices'
	/>
   <serviceDirectory 
        name='openinfoman'
        url='http://csd.ihris.org:8984/CSD/getUpdatedServices'
	username=''
	password=''
	/>
   <serviceDirectory 
        name='openhim'
        url2='https://openhim.jembi.org:5000/CSD/getUpdatedServices'
        url='https://54.204.35.85:5000/CSD/getUpdatedServices'
	username='test'
	password='test'
	/>

</serviceDirectoryLibrary>
;


declare function csd_psd:get_services() { 
  $csd_psd:services_library//serviceDirectory/text{@name}
};

declare function csd_psd:get_service_directory_url($name) {
 text{ $csd_psd:services_library//serviceDirectory[@name=$name]/@url}
};

declare function csd_psd:get_service_directory_password($name) {
 text{ $csd_psd:services_library//serviceDirectory[@name=$name]/@password}
};

declare function csd_psd:get_service_directory_username($name) {
 text{ $csd_psd:services_library//serviceDirectory[@name=$name]/@username}
};




declare function csd_psd:poll_service_directory($name,$mtime) 
{
  let $soap := csd_psd:poll_service_directory_soap_response($name,$mtime)
  return  if ($soap) then
     $soap/soap:Envelope/soap:Body/csd:getModificationsResponse/csd:CSD
  else
    ()
};



declare function csd_psd:poll_service_directory_soap_response($name,$mtime) 
{
  let $url := csd_psd:get_service_directory_url($name)    
  let $boundary := concat("----------------", random:uuid()) 
  let $message :=       <http:multipart media-type='multipart/form-data' boundary="{$boundary}" method='xml' accept='*/*'> 
	<http:header name="Content-Disposition" value="form-data; name=&quot;fileupload&quot;; filename=&quot;soap.xml&quot;"/>
	<http:header name="Content-Type" value="application/xml"/>	
(:	<http:header name="Content-Type" value="application/xml; charset=utf-8"/>	 :)
(:	<http:header name="Media-Type" value="application/xml; charset=utf-8"/>	 :)
(:	<http:header name="Accept" value="*/*"/>	:)
        <http:body   media-type="application/xml" method='xml' >
 	 {csd_qus:create_last_update_request($url,$mtime)} 
        </http:body>      
      </http:multipart>
  let $user := csd_psd:get_service_directory_username($name)
  let $pass := csd_psd:get_service_directory_password($name)
  let $request := 
    if ($user and $pass) 
      then 
      <http:request
      href='{$url}'  
      username='{$user}'
      password='{$pass}'    
      send-authorization='true'
      method='post' >
      {$message}
      </http:request>   
    else
    <http:request
      href='{$url}'  
      method='post' >
      {$message}
    </http:request>   
   
  let $response := http:send-request($request)   
  let $status := text{$response[1]/@status}
  return if ($status = "200") 
  then
    $response[2]    
  else
    ()

};



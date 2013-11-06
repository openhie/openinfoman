(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/his-interop/openinfoman
:
:)
module namespace csd_psd = "https://github.com/his-interop/openinfoman/csd_psd";
import module namespace csd_qus =  "https://github.com/his-interop/openinfoman/csd_qus" at "csd_query_updated_services.xqm";
declare namespace http = "http://expath.org/ns/http-client" ;
declare namespace soap = "http://www.w3.org/2003/05/soap-envelope";
declare namespace csd = "urn:ihe:iti:csd:2013";

declare variable $csd_psd:services_library :=
<serviceDirectoryLibrary>
   <serviceDirectory 
        name='rhea_simple_provider'
        url='http://rhea-pr.ihris.org/providerregistry/getUpdatedServices'
	/>
</serviceDirectoryLibrary>
;


declare function csd_psd:get_services() { 
  $csd_psd:services_library//serviceDirectory/text{@name}
};

declare function csd_psd:get_service_directory_url($name) {
 text{ $csd_psd:services_library//serviceDirectory[@name=$name]/@url}
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
  let $request := <http:request 
      href='{$url}'  
      mime-type="multipart/form-data"
      method='post' >
      <http:body media-type='application/xml; charset=utf-8'>
	{csd_qus:create_last_update_request($mtime)}
      </http:body>
    </http:request>
  let $response := http:send-request($request)   
  let $status := text{$response[1]/@status}
  return if ($status = "200") 
  then
    $response[2]    
  else
    ()

};



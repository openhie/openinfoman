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


declare variable $csd_psd:directory_manager := 'csd_directories.xml';

declare updating function csd_psd:init($db) {
  if ( not(csd_psd:dm_exists($db)))  then
    db:add($db, <serviceDirectoryLibrary/>,$csd_psd:directory_manager)
  else 
      ()
};

declare function csd_psd:dm_exists($db) {
  db:is-xml($db,$csd_psd:directory_manager)
};


declare  function csd_psd:is_registered($db,$name) {
  if ( not(csd_psd:dm_exists($db)))  then
    false()
  else
    let $dm :=  db:open($db,$csd_psd:directory_manager)/serviceDirectoryLibrary
    return exists($dm/serviceDirectory[@name = $name])
};



declare updating function csd_psd:register_service($db,$name,$url,$credentials) {
  let $dm :=  db:open($db,$csd_psd:directory_manager)/serviceDirectoryLibrary
  (:bad bad plain text password:)
  let $reg_doc := <serviceDirectory name="{$name}" url="{$url}">{$credentials}</serviceDirectory>
  let $existing := $dm/serviceDirectory[@name = $name]
  return
    if (not(exists($existing)))  then
      insert node $reg_doc into $dm
    else 
      replace  node $existing with $reg_doc
  

};

declare updating function csd_psd:deregister_service($db,$name) {
  if (csd_psd:dm_exists($db)) then
    let $dm :=  db:open($db,$csd_psd:directory_manager)/serviceDirectoryLibrary
    let $existing := $dm/serviceDirectory[@name = $name]
    return if (exists($existing))  then
      delete node $existing
    else 
      ()
   else ()

};

declare function csd_psd:registered_directories($db) {
  if (csd_psd:dm_exists($db)) then
    db:open($db,$csd_psd:directory_manager)//serviceDirectory/text{@name}
  else
    ()
};



declare function csd_psd:get_service_directory_url($db,$name) {
  text{ db:open($db,$csd_psd:directory_manager)//serviceDirectory[@name=$name]/@url}
};


declare function csd_psd:get_service_directory_credentials($db,$name) {
  db:open($db,$csd_psd:directory_manager)//serviceDirectory[@name=$name]/credentials
};




declare function csd_psd:poll_service_directory($db,$name,$mtime) 
{
  let $soap := csd_psd:poll_service_directory_soap_response($db,$name,$mtime)
  return  if ($soap) then
     $soap/soap:Envelope/soap:Body/csd:getModificationsResponse
(:     $soap//csd:CSD :)
  else
    ()
};


declare function csd_psd:generate_soap_request ($db,$name,$mtime)  {
  let $url := csd_psd:get_service_directory_url($db,$name)    
  let $boundary := concat("----------------", random:uuid()) 
  let $message :=       <http:multipart media-type='multipart/form-data' boundary="{$boundary}" method='xml' accept='*/*'> 
	<http:header name="Content-Disposition" value="form-data; name=&quot;fileupload&quot;; filename=&quot;soap.xml&quot;"/>
	<http:header name="Content-Type" value="application/xml"/>	
        <http:body   media-type="application/xml" method='xml' >
 	 {csd_qus:create_last_update_request($url,$mtime)} 
        </http:body>      
      </http:multipart>     
  let $credentials := csd_psd:get_service_directory_credentials($db,$name)
  let $request := 
    if ($credentials/@type = 'basic_auth' and $credentials/@username ) 
      then 
      <http:request
      href='{$url}'  
      username='{$credentials/username}'
      password='{$credentials/password}'    
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
  return $request
};

declare function csd_psd:poll_service_directory_soap_response($db,$name,$mtime) 
{
  let $request := csd_psd:generate_soap_request($db,$name,$mtime)
  let $response := http:send-request($request)
  let $status := text{$response[1]/@status}
  return if ($status = "200") 
  then
  (    $response[2]    
)
  else
    ()

};



(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/openhie/openinfoman
:
:)
module namespace csd_psd = "https://github.com/openhie/openinfoman/csd_psd";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace csd_qus =  "https://github.com/openhie/openinfoman/csd_qus" ;
import module namespace request = "http://exquery.org/ns/request";
declare namespace http = "http://expath.org/ns/http-client" ;
declare namespace soap = "http://www.w3.org/2003/05/soap-envelope";
declare namespace csd = "urn:ihe:iti:csd:2013";


declare variable $csd_psd:directory_manager := 'csd_directories.xml';

declare updating function csd_psd:init() {
  if ( not(csd_psd:dm_exists()))  then
    db:add($csd_webconf:db, <serviceDirectoryLibrary/>,$csd_psd:directory_manager)
  else 
      ()
};

declare function csd_psd:dm_exists() {
  db:is-xml($csd_webconf:db,$csd_psd:directory_manager)
};


declare  function csd_psd:is_registered($name) {
  if ( not(csd_psd:dm_exists()))  then
    false()
  else
    let $dm :=  db:open($csd_webconf:db,$csd_psd:directory_manager)/serviceDirectoryLibrary
    return exists($dm/serviceDirectory[@name = $name])
};



declare updating function csd_psd:register_service($name,$url,$credentials) {
  let $dm :=  db:open($csd_webconf:db,$csd_psd:directory_manager)/serviceDirectoryLibrary
  (:bad bad plain text password:)
  let $reg_doc := <serviceDirectory name="{$name}" url="{$url}">{$credentials}</serviceDirectory>
  let $existing := $dm/serviceDirectory[@name = $name]
  return
    if (not(exists($existing)))  then
      insert node $reg_doc into $dm
    else 
      replace  node $existing with $reg_doc
  

};


declare function csd_psd:registered_directories() {
  if (csd_psd:dm_exists()) then
    db:open($csd_webconf:db,$csd_psd:directory_manager)//serviceDirectory/text{@name}
  else
    ()
};


declare function csd_psd:get_service_directory_url($name) {
  text{ db:open($csd_webconf:db,$csd_psd:directory_manager)//serviceDirectory[@name=$name]/@url}
};

declare function csd_psd:get_service_directory_credentials($name) {
  db:open($csd_webconf:db,$csd_psd:directory_manager)//serviceDirectory[@name=$name]/credentials
};

declare function csd_psd:poll_service_directory($name,$mtime as xs:dateTime) 
{
  let $soap := csd_psd:poll_service_directory_soap_response($name,$mtime)
  let $resp := $soap/soap:Envelope/soap:Body/csd:getModificationsResponse
  return  if (exists($resp)) then
     $resp
  else
    () 
};



declare function csd_psd:generate_soap_request ($name,$mtime as xs:dateTime)  {
  let $url := csd_psd:get_service_directory_url($name)    
  let $message :=       
    (<http:header name="Content-Type" value="application/soap+xml"/>
     , <http:body   media-type="application/soap+xml">   
        {csd_qus:create_last_update_request($url,$mtime)} 
      </http:body>      
    )
  let $credentials := csd_psd:get_service_directory_credentials($name)
  let $request := 
    if ($credentials/@type = 'basic_auth' and $credentials/@username != '') 
      then 
      <http:request
      href='{$url}'  
      username='{$credentials/@username}'
      password='{$credentials/@password}'    
      send-authorization='true'
      method='post' >
      {$message}
      </http:request>   
    else
    <http:request
      href='{$url}'  
      send-authorization='false'
      method='post' >
      {$message}
    </http:request>   
  return $request
};

declare function csd_psd:poll_service_directory_soap_response($name,$mtime as xs:dateTime) 
{
  let $request := csd_psd:generate_soap_request($name,$mtime)
  let $response := http:send-request($request)
  let $status := text{$response[1]/@status}
  return if ($status = "200") 
  then
  (    $response[2]    
)
  else
    ()
};



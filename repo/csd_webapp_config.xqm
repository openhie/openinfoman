(:~
: This is a module conttaining configuration options for the openinfoman webap
: @version 1.0
: @see https://github.com/his-interop/openinfoman @see http://ihe.net
:
:)

module namespace csd_webconf = "https://github.com/his-interop/openinfoman/csd_webconf";
import module namespace request = "http://exquery.org/ns/request";
declare   namespace   csd = "urn:ihe:iti:csd:2013";


(:Import statements for stored queries.  Each module needs to be imported:)
import module namespace csd_bsq =  "https://github.com/his-interop/openinfoman/csd_bsq" at "csd_base_stored_queries.xqm";
(:
import module namespace csd_hwrsq = "https://github.com/his-interop/openinfoman-hwr/csd_hwrsq" at  "csd_health_worker_registry_stored_queries.xqm";   
import module namespace csd_orsq = "https://github.com/his-interop/openinfoman-hwr/csd_orsq" at  "csd_organization_registry_stored_queries.xqm";   
import module namespace csd_frsq = "https://github.com/his-interop/openinfoman-hwr/csd_frsq" at  "csd_facility_registry_stored_queries.xqm";   
import module namespace csd_srsq = "https://github.com/his-interop/openinfoman-hwr/csd_srsq" at  "csd_service_registry_stored_queries.xqm";   
:)

(:import list of registered stored functions from modules :)
declare variable $csd_webconf:stored_functions :=
(
  $csd_bsq:stored_functions
(:
  , $csd_hwrsq:stored_functions  
  , $csd_orsq:stored_functions  
  , $csd_frsq:stored_functions  
  , $csd_srsq:stored_functions  
:)
);

(:import list of registered stored updating functions from modules :)
declare variable $csd_webconf:stored_updating_functions :=
(
(:
  , $csd_hwrsq:stored_updating_functions  
  , $csd_orsq:stored_updating_functions  
  , $csd_frsq:stored_updating_functions  
  , $csd_srsq:stored_updating_functions  
:)
);


(:Database we are working on:)
declare variable $csd_webconf:db :=  'provider_directory';

(:BASE URL for openinforman. Overwrite this if you are proxying the openinfoman.   :)
declare variable $csd_webconf:baseurl :=  concat(request:scheme(),"://",request:hostname(),":",request:port(), "/"); 



(: DO NOT EDIT BELOW THIS LINE :)



declare function csd_webconf:has_stored_query($uuid) {
  exists($csd_webconf:stored_functions[@uuid = $uuid])
};

declare function csd_webconf:has_updating_stored_query($uuid) {
  exists($csd_webconf:stored_updating_functions[@uuid = $uuid])
};



declare function csd_webconf:execute_stored_query($doc,$uuid,$requestParams) {
  let $definition := $csd_webconf:stored_functions[@uuid = $uuid][1]/csd:definition
  return if (exists($definition))
  then
    xquery:evaluate($definition,map{'':=$doc,'careServicesRequest':=$requestParams})
  else
    ( "nn")

};


declare updating function csd_webconf:execute_stored_updating_query($doc,$uuid,$requestParams) {
  let $definition := $csd_webconf:stored_updating_functions[@uuid = $uuid][1]/csd:definition
  return if (exists($definition))
  then
  db:output(
    xquery:evaluate($definition,map{'':=$doc,'careServicesRequest':=$requestParams})
    )
  else
    ()

};





declare function csd_webconf:lookup_stored_content_type($uuid) 
{
  string(($csd_webconf:stored_functions[@uuid = $uuid]/@content-type , "text/xml")[1])
};



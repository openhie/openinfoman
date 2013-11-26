(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/his-interop/openinfoman
:
:)
module namespace csd_mcs = "https://github.com/his-interop/openinfoman/csd_mcs";
import module namespace csd_lsc = "https://github.com/his-interop/openinfoman/csd_lsc" at "csd_local_services_cache.xqm";
import module namespace csd_psd = "https://github.com/his-interop/openinfoman/csd_psd" at "../repo/csd_poll_service_directories.xqm";

declare namespace csd = "urn:ihe:iti:csd:2013";
declare default element  namespace   "urn:ihe:iti:csd:2013";

declare variable $csd_mcs:merged_services_doc := 'merged_services.xml';


declare function csd_mcs:store_exists($db) {
  db:is-xml($db,$csd_mcs:merged_services_doc)
};



declare updating function csd_mcs:init_store($db) {
  db:add($db, csd_lsc:blank_directory(),$csd_mcs:merged_services_doc)
};

declare updating function csd_mcs:merge($db) {
  let $services := ('rhea_simple_provider')
  return
  (if (csd_mcs:store_exists($db)) 
  then csd_mcs:empty($db) else (),
  csd_mcs:init_store($db),
  for $name in $services
    return csd_lsc:refresh_doc(db:open($db,$csd_mcs:merged_services_doc),csd_lsc:get_cache($db,$name))
  )
    
};



declare function csd_mcs:get($db) {
  db:open($db,$csd_mcs:merged_services_doc)
};


declare updating function csd_mcs:empty($db) {
  db:delete($db,$csd_mcs:merged_services_doc)
};

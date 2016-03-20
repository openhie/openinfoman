(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/openhie/openinfoman
:
:)
module namespace csd_mcs = "https://github.com/openhie/openinfoman/csd_mcs";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace csd_lsc = "https://github.com/openhie/openinfoman/csd_lsc" ;
import module namespace csd_psd = "https://github.com/openhie/openinfoman/csd_psd" ;
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm" ;

declare namespace csd = "urn:ihe:iti:csd:2013";
declare default element  namespace   "urn:ihe:iti:csd:2013";

declare variable $csd_mcs:merged_services_doc := 'merged_services.xml';


declare function csd_mcs:store_exists() {
  db:is-xml($csd_webconf:db, $csd_mcs:merged_services_doc)
};

declare updating function csd_mcs:init_store() {
  db:add($csd_webconf:db, csd_dm:blank_directory(), $csd_mcs:merged_services_doc)
};

(:
: Merges together all documents registered with the document manager
:)
declare updating function csd_mcs:merge($dest,$sources) {

  (: Merges together all cached documents only
  for $name in csd_psd:registered_directories($db)
  return csd_lsc:refresh_doc(db:open($db,$csd_mcs:merged_services_doc),csd_lsc:get_cache($db,$name))
  :)
  let $dest_doc := csd_dm:open_document($dest)
  return 
    if (exists($dest_doc)) 
    then 
      for $name in $sources
      return if ($name != $dest) then
	csd_lsc:refresh_doc($dest_doc, csd_dm:open_document($name))
      else ()
    else ()
    
};

declare function csd_mcs:get() {
  db:open($csd_webconf:db,$csd_mcs:merged_services_doc)
};


declare updating function csd_mcs:empty() {
  db:replace($csd_webconf:db, $csd_mcs:merged_services_doc, csd_dm:blank_directory())
};


declare function csd_mcs:get_merge_doc_name() {
  let $name := 'merged_remote_services'
  return $name
};
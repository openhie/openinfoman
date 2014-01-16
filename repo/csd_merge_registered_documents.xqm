(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/his-interop/openinfoman
:
:)
module namespace csd_mrd = "https://github.com/his-interop/openinfoman/csd_mrd";
import module namespace csd_lsc = "https://github.com/his-interop/openinfoman/csd_lsc" at "csd_local_services_cache.xqm";
import module namespace csd_dm = "https://github.com/his-interop/openinfoman/csd_dm" at "../repo/csd_document_manager.xqm";

declare namespace csd = "urn:ihe:iti:csd:2013";
declare default element  namespace   "urn:ihe:iti:csd:2013";

declare variable $csd_mrd:merged_services_doc := 'merged_services.xml';


declare function csd_mrd:store_exists($db) {
  db:is-xml($db, $csd_mrd:merged_services_doc)
};

declare updating function csd_mrd:init_store($db) {
  db:add($db, csd_lsc:blank_directory(), $csd_mrd:merged_services_doc)
};

(:
: Merges together all documents registered with the document manager
:)
declare updating function csd_mrd:merge($db) {
  for $name in csd_dm:registered_documents($db)
  return if ($name != csd_mrd:get_merge_doc_name()) then
    csd_lsc:refresh_doc(db:open($db, $csd_mrd:merged_services_doc), csd_dm:open_document($db, $name))
  else ()
};

declare function csd_mrd:get($db) {
  db:open($db,$csd_mrd:merged_services_doc)
};


declare updating function csd_mrd:empty($db) {
  db:replace($db, $csd_mrd:merged_services_doc, csd_lsc:blank_directory())
};


declare function csd_mrd:get_merge_doc_name() {
  let $name := 'merged_remote_services'
  return $name
};
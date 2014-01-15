(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/his-interop/openinfoman
:
:)
module namespace csd_dm = "https://github.com/his-interop/openinfoman/csd_dm";

(:import module namespace csd_mcs = "https://github.com/his-interop/openinfoman/csd_mcs" at "csd_merge_cached_services.xqm";:)

declare namespace csd = "urn:ihe:iti:csd:2013";
declare default element  namespace   "urn:ihe:iti:csd:2013";

declare variable $csd_dm:document_manager := 'csd_docs.xml';

declare updating function csd_dm:init($db) {
  if ( not(csd_dm:dm_exists($db)))  then
    db:add($db, <documentLibrary/>,$csd_dm:document_manager)
  else 
      ()
};

declare function csd_dm:dm_exists($db) {
  db:is-xml($db,$csd_dm:document_manager)
};

declare  function csd_dm:document_source_exists($db,$name) {
  let $source := csd_dm:document_source($db,$name)
  return  (db:is-xml($db,$source)) 

};

declare  function csd_dm:open_document($db,$name) {
  if (csd_dm:document_source_exists($db,$name)) then      
    db:open($db,csd_dm:document_source($db,$name))
  else
    ()
};


declare updating function csd_dm:register_document($db,$name,$source) {
  let $dm :=  db:open($db,$csd_dm:document_manager)/documentLibrary
  let $reg_doc := <document name="{$name}" source="{$source}"/>
  let $existing := $dm/document[@name = $name]
  return if (not(exists($existing)))  then 
       (insert node $reg_doc into $dm (:, csd_mcs:merge($db) :) )
     else  
       (replace  node $existing with $reg_doc (:, csd_mcs:merge($db) :)) 
};


declare  function csd_dm:is_registered($db,$name) {
  if (csd_dm:dm_exists($db)) then
    let $dm :=  db:open($db,$csd_dm:document_manager)/documentLibrary
    let $existing := $dm/document[@name = $name]
    return exists($existing)
  else 
    false()

};

declare updating function csd_dm:deregister_document($db,$name) {
  if (csd_dm:dm_exists($db)) then
    let $dm :=  db:open($db,$csd_dm:document_manager)/documentLibrary
    let $existing := $dm/document[@name = $name]
    return if (exists($existing))  then
      (delete node $existing(:, csd_mcs:merge($db):))
    else ()
  else ()

};

declare function csd_dm:registered_documents($db) {
  if (csd_dm:dm_exists($db)) then
    for $name in db:open($db,$csd_dm:document_manager)/documentLibrary/document/text{@name}
    where csd_dm:document_source_exists($db,$name)
      return $name
  else
    ()
};

declare function csd_dm:document_source($db,$name) {
    db:open($db,$csd_dm:document_manager)/documentLibrary/document[@name = $name]/@source
};


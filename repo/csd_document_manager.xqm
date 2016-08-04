(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/openhie/openinfoman
:
:)
module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";

import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
declare namespace csd = "urn:ihe:iti:csd:2013";
declare default element  namespace   "urn:ihe:iti:csd:2013";

declare variable $csd_dm:document_manager := 'csd_docs.xml';

declare function csd_dm:blank_directory()
{
<CSD xmlns:csd="urn:ihe:iti:csd:2013" xmlns="urn:ihe:iti:csd:2013">
  <organizationDirectory/>
  <serviceDirectory/>
  <facilityDirectory/>
  <providerDirectory/>
</CSD>
};





declare  function csd_dm:document_source_exists($name) {
  let $source := csd_dm:document_source($name)
  return  if ($source) then (db:is-xml($csd_webconf:db,$source)) else false()

};

declare  function csd_dm:open_document($name) {
  csd_dm:open_document($name,false())
};

declare  function csd_dm:open_document($name,$updating) {
  if (csd_dm:document_source_exists($name)) then      
    if ($updating) 
    then db:open($csd_webconf:db,csd_dm:document_source($name)) 
    else db:open($csd_webconf:db,csd_dm:document_source($name)) update{} (:stick it in main memory :)
  else
    csd_dm:blank_directory()
};

declare updating function csd_dm:add($doc,$name) {
  csd_dm:empty($name,$doc)
};



declare updating function csd_dm:delete($name) {
  db:delete($csd_webconf:db,csd_dm:document_source($name))
};

declare updating function csd_dm:empty($name) {
  csd_dm:empty($name,csd_dm:blank_directory())
};

declare updating function csd_dm:empty($name,$doc) {
  let $source := csd_dm:document_source($name)
  return 
    if (csd_dm:document_source_exists($name)) then
      db:replace($csd_webconf:db,$source,$doc)
    else
      db:add($csd_webconf:db,$doc,$source) 
    
};

declare function csd_dm:registered_documents() {
(:  db:list("service_directories/*") :)
  for $doc in db:list($csd_webconf:db,"service_directories")
  let $name := csd_dm:fn_base_name($doc,'.xml')
  return $name
};

declare function csd_dm:document_source($name) {
  concat("service_directories/",string($name),".xml")
};


declare function csd_dm:fn_base_name($file,$ext) {
  let $old_base_name := fn:function-lookup(xs:QName("file:base-name"), 2)
  return
    if (not(exists($old_base_name))) then
      fn:replace(fn:function-lookup(xs:QName("file:name"), 1)($file), fn:concat($ext, "$"), "")
    else
      $old_base_name($file,$ext)
};


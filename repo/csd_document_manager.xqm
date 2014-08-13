(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/openhie/openinfoman
:
:)
module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";


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





declare  function csd_dm:document_source_exists($db,$name) {
  let $source := csd_dm:document_source($name)
  return  if ($source) then (db:is-xml($db,$source)) else false()

};

declare  function csd_dm:open_document($db,$name) {
  if (csd_dm:document_source_exists($db,$name)) then      
    db:open($db,csd_dm:document_source($name))
  else
    csd_dm:blank_directory()
};

declare updating function csd_dm:add($db,$doc,$name) {
  db:add($db, $doc, csd_dm:document_source($name))
};



declare updating function csd_dm:delete($db,$name) {
  db:delete($db,csd_dm:document_source($name))
};

declare updating function csd_dm:empty($db,$name) {
  csd_dm:empty($db,$name,csd_dm:blank_directory())
};

declare updating function csd_dm:empty($db,$name,$doc) {
  let $source := csd_dm:document_source($name)
  return 
    if (csd_dm:document_source_exists($db,$name)) then
      db:replace($db,$source,$doc)
    else 
      db:add($db,$doc,$source)
  
};

declare function csd_dm:registered_documents($db) {
(:  db:list($db,"service_directories/*") :)
  for $doc in db:list($db,"service_directories")
  let $name := csd_dm:fn_base_name($doc,'.xml')
  return $name
};

declare function csd_dm:document_source($name) {
  concat("service_directories/",$name,".xml")
};


declare function csd_dm:fn_base_name($file,$ext) {
  let $old_base_name := fn:function-lookup(xs:QName("file:base-name"), 2)
  return
    if (not(exists($old_base_name))) then
      fn:replace(fn:function-lookup(xs:QName("file:name"), 1)($file), fn:concat($ext, "$"), "")
    else
      $old_base_name($file,$ext)
};


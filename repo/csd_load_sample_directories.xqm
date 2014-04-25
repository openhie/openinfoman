(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/his-interop/openinfoman
:
:)
module namespace csd_lsd = "https://github.com/his-interop/openinfoman/csd_lsd";

declare variable $csd_lsd:base_path := "../resources/service_directories/";

declare function csd_lsd:fn_base_name($file,$ext) {
  let $old_base_name := fn:function-lookup(xs:QName("file:base-name"), 2)
  return
    if (not(exists($old_base_name))) then
      fn:replace(fn:function-lookup(xs:QName("file:name"), 1)($file), fn:concat($ext, "$"), "")
    else
      $old_base_name($file,$ext)
};

declare function csd_lsd:sample_directories() {
  let $files := file:list($csd_lsd:base_path,true(),'*.xml')
  for $file in $files
    return csd_lsd:fn_base_name($file,".xml")
};

declare function csd_lsd:get_document_names() {
  csd_lsd:get_document_name(csd_lsd:sample_directories())
};



declare function csd_lsd:get_document_name($name) {
  concat("service_directories/",$name,".xml")
};

declare function csd_lsd:get_document_source($name) {
  concat($csd_lsd:base_path, "/" , $name,".xml")
};

declare function csd_lsd:exists($db,$name) {
  db:is-xml($db,csd_lsd:get_document_name($name)) and csd_lsd:valid_doc($name)
};

declare function csd_lsd:valid_doc($name) {
  $name = csd_lsd:sample_directories()
};


declare updating function csd_lsd:load($db,$name) {
  if (not(csd_lsd:exists($db,$name)) and csd_lsd:valid_doc($name)) then
    db:add($db, csd_lsd:get_document_source($name),csd_lsd:get_document_name($name))
  else 
    ()
};


declare function csd_lsd:get($db,$name) {
  if (csd_lsd:exists($db,$name)) then
    db:open($db,csd_lsd:get_document_name($name))
  else
    ()
};

declare updating function csd_lsd:delete($db,$name) {
  if (csd_lsd:exists($db,$name) and csd_lsd:valid_doc($name)) then
    db:delete($db,csd_lsd:get_document_name($name))
  else
    ()
};


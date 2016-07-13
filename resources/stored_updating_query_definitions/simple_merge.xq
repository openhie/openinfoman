import module namespace csd_lsc = "https://github.com/openhie/openinfoman/csd_lsc";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace functx = "http://www.functx.com";
declare namespace csd  =  "urn:ihe:iti:csd:2013";

declare variable $careServicesRequest as item() external;


let $overwriteExisting := 
  if (exists($careServicesRequest/overwriteExisting/@value))
  then ($careServicesRequest/overwriteExisting/@value = 1)
  else true()


let $dest_doc := /.
let $dest := $careServicesRequest/@resource

for $doc  in $careServicesRequest/documents/document
  let $name := $doc/@resource
  let $src_doc :=
    if (not (functx:all-whitespace($name)))
    then if (not ($name = $dest)) then csd_dm:open_document($name) else ()
    else $doc
  return  
    csd_lsc:refresh_doc($dest_doc, $src_doc,$overwriteExisting) 




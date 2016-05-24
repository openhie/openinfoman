import module namespace csd_lsc = "https://github.com/openhie/openinfoman/csd_lsc";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
declare namespace csd  =  "urn:ihe:iti:csd:2013";

declare variable $careServicesRequest as item() external;

let $doc_name := string($careServicesRequest/@resource)
let $doc := csd_dm:open_document($doc_name)

let $masterID := $careServicesRequest/csd:requestParams/masterEntity/@entityID

let $dupID := $careServicesRequest/csd:requestParams/duplicateEntity/@entityID
let $dupEntity :=  if (exists($dupID)) then (/csd:CSD/*/*[@entityID = $dupID])[1] else ()


let $dupRef := $dupEntity/csd:otherID[@assigningAuthorityName='urn:openhie.org:openinfoman' and @code='potential-duplicate' and text()=$masterID]

return 
  if (exists($dupRef))
  then delete node $dupRef
  else ()

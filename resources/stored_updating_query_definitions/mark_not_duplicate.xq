import module namespace csd_lsc = "https://github.com/openhie/openinfoman/csd_lsc";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
declare namespace csd  =  "urn:ihe:iti:csd:2013";

declare variable $careServicesRequest as item() external;

let $doc_name := string($careServicesRequest/@resource)
let $doc := csd_dm:open_document($doc_name)

let $masterID := $careServicesRequest/masterEntity/@entityID
let $masterEntity := if (exists($masterID)) then  (/csd:CSD/*/*[@entityID = $masterID])[1] else ()

let $notdupID := $careServicesRequest/notDuplicateEntity/@entityID
let $notdupEntity :=  if (exists($notdupID)) then (/csd:CSD/*/*[@entityID = $notdupID])[1] else ()


let $masterRef := <csd:otherID assigningAuthorityName='urn:openhie.org:openinfoman' code='not-duplicate'>{string($masterID)}</csd:otherID>

return 
  if (not(exists($masterEntity)) or not( exists($notdupEntity)))
  then ()
  else 
    let $existingRef := ($notdupEntity/csd:otherID[@assigningAuthorityName = 'urn:openhie.org:openinfoman' and @code='not-duplicate' and ./text()=$masterID])[1]
    return 
      (
	if (exists($existingRef))
	then (replace node $existingRef with $masterRef)
	else (insert node $masterRef before ($notdupEntity/*)[1])
	   )
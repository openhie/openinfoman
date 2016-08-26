import module namespace csd_lsc = "https://github.com/openhie/openinfoman/csd_lsc";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
declare namespace csd  =  "urn:ihe:iti:csd:2013";

declare variable $careServicesRequest as item() external;

let $doc_name := string($careServicesRequest/@resource)
let $doc := csd_dm:open_document($doc_name)

let $masterID := $careServicesRequest/masterEntity/@entityID
let $masterEntity := if (exists($masterID)) then  (/csd:CSD/*/*[@entityID = $masterID])[1] else ()

let $ndupID := $careServicesRequest/notDuplicateEntity/@entityID
let $ndupEntity :=  if (exists($ndupID)) then (/csd:CSD/*/*[@entityID = $ndupID])[1] else ()


let $masterRef := <csd:otherID assigningAuthorityName='urn:openhie.org:openinfoman' code='not-duplicate'>{string($masterID)}</csd:otherID>

return 
  if (not(exists($masterEntity)) or not( exists($ndupEntity)))
  then ()
  else 
    let $existingRef := ($ndupEntity/csd:otherID[@assigningAuthorityName = 'urn:openhie.org:openinfoman' and @code='not-duplicate'])[1]
    return 
      (
	if (exists($existingRef))
	then (replace node $existingRef with $masterRef)
	else (insert node $masterRef before ($ndupEntity/*)[1])
      ,
        for $entity in /csd:CSD/*/*[./csd:otherID[@assigningAuthorityName='urn:openhie.org:openinfoman' and @code='not-duplicate' and ./text()=$ndupID]]
	let $e_existingRef := ($entity/csd:otherID[@assigningAuthorityName='urn:openhie.org:openinfoman' and @code='not-duplicate' and  ./text()=$ndupID])[1]
	return 
	  if (not($e_existingRef = $existingRef)  )
	  then replace node $e_existingRef with $masterRef
	  else () (:avoid double replacelement in edge case in which a record is marked as duplicate to itself:)
     )



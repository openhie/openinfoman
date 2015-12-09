import module namespace csd_lsc = "https://github.com/openhie/openinfoman/csd_lsc";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
declare namespace csd  =  "urn:ihe:iti:csd:2013";

declare variable $careServicesRequest as item() external;

let $doc_name := string($careServicesRequest/@resource)
let $doc := csd_dm:open_document($csd_webconf:db,$doc_name)

let $masterID := $careServicesRequest/masterEntity/@entityID
let $masterEntity := if (exists($masterID)) then  (/csd:CSD/*/*[@entityID = @masterID])[1] else ()

let $dupID := $careServicesRequest/duplicateEntity/@entityID
let $dupEntity :=  if (exists($dupID)) then (/csd:CSD/*/*[@entityID = @dupID])[1] else ()


let $masterRef := <csd:otherID assigningAuthorityName='urn:openhie.org:openinfoman:duplicate' code="{$masterID}"/>

return 
  if (not(exists($masterEntity)) or not( exists($dupEntity)))
  then ()
  else 
    let $existingRef := ($dupEntity/csd:otherID[@assigningAuthorityName = 'urn:openhie.org:openinfoman:duplicate'])[1]
    return 
      (
	if (exists($existingRef))
	then (replace node $existingRef with $masterRef)
	else (insert node $masterRef before ($dupEntity/*)[1])
      ,
        for $entity in /csd:CSD/*/*[./csd:otherID[@assigningAuthorityName='urn:openhie.org:openinfoman:duplicate' and @code=$dupID]]
	let $e_existingRef := ($entity/csd:otherID[@assigningAuthorityName='urn:openhie.org:openinfoman:duplicate' and  @code=$dupID])[1]
	return (replace node $e_existingRef with $masterRef)
     )



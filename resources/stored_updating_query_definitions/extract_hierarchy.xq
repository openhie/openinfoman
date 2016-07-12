import module namespace csd_lsc = "https://github.com/openhie/openinfoman/csd_lsc";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace functx = "http://www.functx.com";
import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
declare namespace csd  =  "urn:ihe:iti:csd:2013";

declare variable $careServicesRequest as item() external;



let $dest_doc := /.
let $dest := $careServicesRequest/@resource

let $doc :=  $careServicesRequest/document
let $name := $doc/@resource
let $src_doc :=
  if (not (functx:all-whitespace($name)))
  then if (not ($name = $dest)) then csd_dm:open_document($name) else ()
  else $doc
let $req_org_id :=    $careServicesRequest/csd:organization/@entityID 

let $processFacilities := 
  if (exists($careServicesRequest/processFacilities/@value))
  then ($careServicesRequest/processFacilities/@value = 1)
  else true()
let $keepParents := 
  if (exists($careServicesRequest/keepParents/@value))
  then ($careServicesRequest/keepParents/@value = 1)
  else true()
    
let $all_orgs := $src_doc/csd:CSD/csd:organizationDirectory/csd:organization
let $org := $all_orgs[@entityID = $req_org_id]



let $orgs := 
  if (not(exists($org)))
  then () (: nothing to extract:) 
  else
     (
       if ($keepParents)
       then csd_bl:get_parent_orgs($all_orgs,$org)
       else ()
       ,
       $org
       ,
       csd_bl:get_child_orgs($all_orgs,$org)
     )

let $facs := 
  if (not ($processFacilities) )
  then ()
  else 
    for $org in $orgs
    return  $src_doc/csd:CSD/csd:facilityDirectory/csd:facility[./csd:organizations/csd:organization/@entityID = $org/@entityID]



return
  (
   csd_lsc:update_directory($dest_doc/csd:CSD/csd:organizationDirectory,$orgs)
  ,csd_lsc:update_directory($dest_doc/csd:CSD/csd:facilityDirectory,$facs)
  )




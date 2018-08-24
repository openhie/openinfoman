import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
declare namespace csd = "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

let $name := $careServicesRequest/csd:service/text()
   let $t0 := trace($name, "serv name= ")
   let $dm :=  db:open($csd_webconf:db,'csd_directories.xml')/serviceDirectoryLibrary
  let $existing := $dm/serviceDirectory[@name = $name]
  return
   if (exists($existing))  then
           delete  node $existing
   else  ()
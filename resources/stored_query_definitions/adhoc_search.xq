import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
declare namespace csd  =  "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;


let $expr :=$careServicesRequest/adhoc/text()

return 
  if ($expr) 
  then xquery:eval($expr,map{"":=/.})
  else ()

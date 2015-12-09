import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
(:
import module namespace random = "http://basex.org/modules/random";
:)
import module namespace csd_blu = "https://github.com/openhie/openinfoman/csd_blu";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 
for $prov in $careServicesRequest/csd:provider
  let $existing := if (exists($prov/@entityID)) then csd_bl:filter_by_primary_id(/CSD/providerDirectory/*,$prov/@entityID) else ()  
  return
    if (exists($existing)) 
    then insert node $prov into /CSD/providerDirectory
    else replace node $existing with $prov

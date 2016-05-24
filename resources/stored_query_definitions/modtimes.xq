declare namespace csd = 'urn:ihe:iti:csd:2013';
declare variable $careServicesRequest as item() external;
let $ptime := max( for $dt in /csd:CSD/csd:providerDirectory/csd:provider/csd:record/@updated return xs:dateTime($dt))
let $otime := max( for $dt in /csd:CSD/csd:organizationDirectory/csd:organization/csd:record/@updated return xs:dateTime($dt))
let $ftime := max( for $dt in /csd:CSD/csd:facilityDirectory/csd:facility/csd:record/@updated return xs:dateTime($dt))
let $stime := max( for $dt in /csd:CSD/csd:serviceDirectory/csd:service/csd:record/@updated return xs:dateTime($dt))
let $time := max (($ptime,$otime,$ftime,$stime))
return 
  <csd:CSD updated="{$time}">
    <csd:providerDirectory updated="{$ptime}"/>
    <csd:facilityDirectory updated="{$ftime}"/>
    <csd:organizationDirectory updated="{$otime}"/>
    <csd:serviceDirectory updated="{$stime}"/>
  </csd:CSD>
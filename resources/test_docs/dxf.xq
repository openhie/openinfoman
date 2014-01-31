declare namespace csd = "urn:ihe:iti:csd:2013";

declare variable $facilities := /csd:CSD/csd:facilityDirectory/csd:facility;
declare variable $providers := /csd:CSD/csd:providerDirectory/csd:provider;

<dxf xmlns="http://dhis2.org/schema/dxf/2.0">
<dataValueSet>
{
  for $fac in $facilities
    let $facoid := $fac/@oid
    let $faccode := $fac/csd:otherID[@assigningAuthorityName="dhis2-uid"]/@code
    let $facProviders := $providers[csd:facilities/csd:facility/@oid=$facoid]
    
    where $faccode
    
    return 
    <dataValue period='2013Q4' orgUnit='{$faccode}' dataElement='numProviders' value='{count($facProviders)}'/>
}
</dataValueSet>
</dxf>
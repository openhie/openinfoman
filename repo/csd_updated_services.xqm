(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/his-interop/openinfoman
:
:)
module namespace csd_us = "https://github.com/his-interop/openinfoman/csd_us";


declare   namespace   csd = "urn:ihe:iti:csd:2013";
declare namespace soap="http://www.w3.org/2003/05/soap-envelope";
declare namespace wsa="http://www.w3.org/2005/08/addressing" ;
declare default element  namespace   "urn:ihe:iti:csd:2013";

declare function csd_us:get_updated_services_soap($soap,$doc) {
  let $last_mtime := $soap/soap:Envelope/csd:getModificationsRequest/csd:lastModified
  let $msgID := $soap/soap:Envelope/soap:Header/was:MessageID
  return csr_us:wrap_in_soap_response(csd_us:get_update_services($time,$doc),$msgID)
};

declare function csd_us:get_updated_services($last_mtime,$doc) {
  return if ($last_mtime)  then
   <csd:CSD>
      <organizationDirectory>
	{$doc/csd:CSD/organizatioDirectory/organization[./record/@updated >= $last_mtime]}
      </organizationDirectory>
      <serviceDirectory>
	{$doc/csd:CSD/serviceDirectory/service[./record/@updated >= $last_mtime]}
      </serviceDirectory>
      <facilityDirectory>
	{$doc/csd:CSD/facilityDirectory/facility[./record/@updated >= $last_mtime]}
      </facilityDirectory>
      <providerDirectory>
	{$doc/csd:CSD/provdiderDirectory/provider[./record/@updated >= $last_mtime]}
      </providerDirectory>
    </csd:CSD>
  else 
    $doc
};

declare function csd_us:wrap_in_soap_response($csd,$msgID) {
<soap:Envelope 
 xmlns:soap="http://www.w3.org/2003/05/soap-envelope" 
 xmlns:wsa="http://www.w3.org/2005/08/addressing" 
 xmlns:csd="urn:ihe:iti:csd:2013"> 
  <soap:Header>
    <wsa:Action soap:mustUnderstand="1" >urn:ihe:iti:csd:2013:GetDirectoryModificationsResponse</wsa:Action>
    <wsa:MessageID>urn:uuid:{random:uuid()}</wsa:MessageID>
    <wsa:To soap:mustUnderstand="1">http://www.w3.org/2005/08/addressing/anonymous</wsa:To> 
    <wsa:RelatesTo>{$msgID}</wsa:RelatesTo>
  </soap:Header>
  <soap:Body>
    <csd:getModificationsResponse>
    {$csd}
    </csd:getModificationsResponse>
  </soap:Body>
</soap:Envelope>
}


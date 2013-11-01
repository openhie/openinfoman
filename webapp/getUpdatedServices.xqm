module namespace page = 'http://basex.org/modules/web-page';

import module namespace csd_qus = "https://github.com/his-interop/openinfoman/csd_qus" at "../repo/csd_query_updated_services.xqm";

declare namespace soap = "http://www.w3.org/2003/05/soap-envelope";

declare
  %rest:path("/CSD/getUpdatedServices")
  %rest:consumes("application/xml", "text/xml", "multipart/form-data")
  %rest:POST("{$updatedServicesRequest}")
  function page:updated_services($updatedServicesRequest) 
{ 
for $doc in collection('provider_directory')
where matches(document-uri($doc), 'providers.xml')
return csd_qus:get_updated_services_soap($updatedServicesRequest/soap:Envelope,$doc)   

};


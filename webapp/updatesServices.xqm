module namespace page = 'http://basex.org/modules/web-page';

import module namespace csd_us = "https://github.com/his-interop/openinfoman/us" at "../repo/csd_updated_services.xqm";


declare
  %rest:path("/CSD/updatedServices")
  %rest:consumes("application/xml", "text/xml", "multipart/form-data")
  %rest:POST("{$updatedServicesRequest}")
  function page:updated_services($updatedServicesRequest) 
{ 
for $doc in collection('provider_directory')
where matches(document-uri($doc), 'providers.xml')
return cds_us:get_updated_services_soap($updatedServicesRequest/soap:Envelope,$doc)   

};

declare
  %rest:path("/CSD/updatesServces")
  %rest:consumes("application/x-www-form-urlencoded")
  %rest:POST("{$careServicesRequest}")
  function page:updated_services_encoded($updatedServicesRequest) 
{ 
 page:get_updated_services(parse-xml($updatedServicesRequest))
};


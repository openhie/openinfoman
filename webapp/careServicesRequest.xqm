module namespace page = 'http://basex.org/modules/web-page';
import module namespace csd = "urn:ihe:iti:csd:2013" at "../repo/csd_base_library.xqm";
import module namespace csr_proc = "https://github.com/his-interop/openinfoman/csr_proc" at "../repo/csr_processor.xqm";

declare default element  namespace   "urn:ihe:iti:csd:2013";


declare
  %rest:path("/CSD/careServicesRequest")
  %rest:consumes("application/xml", "text/xml", "multipart/form-data")
  %rest:POST("{$careServicesRequest}")
  function page:process_CSR_post($careServicesRequest) 
{
for $doc in collection('provider_directory')
where matches(document-uri($doc), 'providers.xml')
return csr_proc:process_CSR($careServicesRequest/careServicesRequest,$doc)  
};


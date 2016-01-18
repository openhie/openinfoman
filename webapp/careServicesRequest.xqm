module namespace page = 'http://basex.org/modules/web-page';

import module namespace csr_proc = "https://github.com/openhie/openinfoman/csr_proc";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace csd_webui =  "https://github.com/openhie/openinfoman/csd_webui";


declare   namespace   csd = "urn:ihe:iti:csd:2013";
declare default element  namespace   "urn:ihe:iti:csd:2013";

declare variable $page:csd_docs := csd_dm:registered_documents($csd_webconf:db);

declare
  %rest:path("/CSD/csr/{$name}/careServicesRequest")
  %rest:POST("{$careServicesRequest}")
  function page:csr($name,$careServicesRequest) 
{ 
if (csd_dm:document_source_exists($csd_webconf:db,$name)) then 
 csr_proc:process_CSR($csd_webconf:db,$careServicesRequest/careServicesRequest,$name,csd_webui:generateURL())
else
  (:need appropriate error handling:)
  ()

};


declare
  %rest:path("/CSD/csr/{$name}/careServicesRequest/{$search}")
  %rest:consumes("application/xml", "text/xml", "multipart/form-data")  
  %rest:POST("{$requestParams}")
  function page:csr2($name,$requestParams,$search) 
{ 
let $careServicesRequest :=
  <csd:careServicesRequest>
    <csd:function urn="{$search}">{$requestParams}</csd:function>
  </csd:careServicesRequest>
return 
  if (csd_dm:document_source_exists($csd_webconf:db,$name)) then 
    csr_proc:process_CSR($csd_webconf:db,$careServicesRequest,$name,csd_webui:generateURL())
  else
    (:need appropriate error handling:)
  ()

};

declare updating
  %rest:path("/CSD/csr/{$name}/careServicesRequest/update")
  %rest:consumes("application/xml", "text/xml", "multipart/form-data")  
  %rest:POST("{$careServicesRequest}")
  function page:csr_updating($name,$careServicesRequest) 
{ 
  if (csd_dm:document_source_exists($csd_webconf:db,$name)) then 
    csr_proc:process_updating_CSR($csd_webconf:db,$careServicesRequest/csd:careServicesRequest,$name,csd_webui:generateURL())
  else
    (:need appropriate error handling:)
    ()
};


declare updating
  %rest:path("/CSD/csr/{$name}/careServicesRequest/update/{$search}")
  %rest:consumes("application/xml", "text/xml", "multipart/form-data")  
  %rest:POST("{$requestParams}")
  function page:csr_updating($name,$requestParams,$search) 
{ 
let $careServicesRequest :=
  <csd:careServicesRequest>
    <csd:function urn="{$search}">{$requestParams}</csd:function>
  </csd:careServicesRequest>
return
if (csd_dm:document_source_exists($csd_webconf:db,$name)) then 
 csr_proc:process_updating_CSR($csd_webconf:db,$careServicesRequest,$name,csd_webui:generateURL())
else
  (:need appropriate error handling:)
  ()

};


declare
  %rest:path("/CSD/csr/{$name}/adhoc")
  %rest:consumes("application/xml", "text/xml", "multipart/form-data")
  %rest:POST
  %rest:form-param("adhoc","{$adhoc}")
  %rest:form-param("content", "{$content}","application/xml")
function page:adhoc($name,$adhoc,$content) {    
if (csd_dm:document_source_exists($csd_webconf:db,$name)) then 
let  $adhoc_doc := csr_proc:create_adhoc_doc(string($adhoc),$content)
  return  csr_proc:process_CSR($csd_webconf:db, $adhoc_doc,$name,csd_webui:generateURL())
else
  (:need appropriate error handling:)
  ()

};



declare
  %rest:path("/CSD/csr")
  %rest:GET
  %output:method("xhtml")
  function page:csr_list() 
{ 
let $response := page:endpoints()
return csd_webconf:wrapper($response)
};



declare function page:endpoints() {
<span>
    <h2>Care Services Request - Endpoints</h2>
    <ul>
      {
	for $name in $page:csd_docs
	return 
	<li>
	  Submit Care Services Request for {$name} at:
	  <pre>{csd_webui:generateURL(('CSD/csr/',$name,'/careServicesRequest'))}</pre> 
	  <br/>
	  Submit ad-hoc query:
	  <form method='post' action="/CSD/csr/{$name}/adhoc"  enctype="multipart/form-data">
	    <label for="adhoc">Ad-Hoc Query</label><textarea  rows="10" cols="80" name="adhoc" >{$page:sample}</textarea>
	    <br/>
	    <label for="content">Content Type</label><input    cols="80" name="content" value="text/html"/>
	    <br/>
	    <input type="submit" value="submit"/>
	  </form>
	</li>
      }
    </ul>
  </span>
};






declare variable $page:sample := 
"declare namespace csd = 'urn:ihe:iti:csd:2013';
<html>
 <body>
  <ul>
   <li>You have {count(/csd:CSD/csd:providerDirectory/*)} providers.</li>
   <li>You have {count(/csd:CSD/csd:facilityDirectory/*)} facilities.</li>
   <li>You have {count(/csd:CSD/csd:organizationDirectory/*)} organizations.</li>
   <li>You have {count(/csd:CSD/csd:serviceDirectory/*)} services.</li>
  </ul>
 </body>
</html>";





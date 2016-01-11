module namespace page = 'http://basex.org/modules/web-page';

import module namespace csd_lsd = "https://github.com/openhie/openinfoman/csd_lsd";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace csr_proc = "https://github.com/openhie/openinfoman/csr_proc";


declare function page:redirect($redirect as xs:string) as element(restxq:redirect)
{
  <restxq:redirect>{ $redirect }</restxq:redirect>
};

declare function page:nocache($response) 
{(
  <rest:response>
    <http:response >
      <http:header name="Cache-Control" value="must-revalidate,no-cache,no-store"/>
    </http:response>
  </rest:response>
  ,
  $response
)};



declare
  %rest:path("/CSD/initSampleDirectory/directory/{$name}")
  %rest:GET
  %output:method("xhtml")
  function page:get_service_menu($name)
{
  let $response := page:services_menu($name) 
  return page:nocache(csd_webconf:wrapper($response))
};

declare
  %rest:path("/CSD/initSampleDirectory/directory/{$name}/get")
  %rest:GET
  function page:get_directory($name)
{
  csd_dm:open_document($csd_webconf:db,$name) 
};





declare updating   
  %rest:path("/CSD/initSampleDirectory/directory/{$name}/load")
  %rest:GET
  function page:load($name)
{ 
(
  csd_lsd:load($csd_webconf:db,$name)   ,
  db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/initSampleDirectory")))
)
};



declare updating   
  %rest:path("/CSD/initSampleDirectory/directory/{$name}/reload")
  %rest:GET
  function page:reload($name)
{ 
(
  csd_dm:empty($csd_webconf:db,$name)   ,
  db:output(page:redirect(concat($csd_webconf:baseurl,concat("CSD/initSampleDirectory/directory/",$name,"/load"))))
)


};




declare
  %rest:path("/CSD/initSampleDirectory")
  %rest:GET
  %output:method("xhtml")
  function page:directory_list()
{ 
let $response :=
      <div class='row'>
 	<div class="col-md-8">
	  <h2>Sample Directories</h2>
	  <ul>
	    {for $name in csd_lsd:sample_directories()
	    order by $name
	    return 
	    <li>
	      <a href="/CSD/initSampleDirectory/directory/{$name}">{$name}</a>
	      <br/>
	      {page:services_menu($name)}
	    </li>
	    }
	  </ul>
	</div>
      </div>

return page:nocache(  csd_webconf:wrapper($response))


};




declare 
  %rest:path("/CSD/documents.json")
  %rest:GET
  function page:export_function_details_json(){    
  (<rest:response>
    <output:serialization-parameters>
      <output:media-type value='application/json'/>
    </output:serialization-parameters>
  </rest:response>,
  xml-to-json( page:get_export_document_details())
    )
};

declare
  %rest:path("/CSD/documents.xml")
  %rest:GET
  function page:export_document_details_xml(){
    
    page:get_export_document_details()
};

declare function page:get_export_document_details() {
  <map xmlns="http://www.w3.org/2005/xpath-functions">
    {
      for $name in csd_dm:registered_documents($csd_webconf:db)
      return 
      <map key="{string($name)}">
	<string key="careServicesRequest">{$csd_webconf:baseurl}CSD/csr/{$name}/careServicesRequest</string>
	<map key="careServicesRequests">
	  {
	    for $function in (csr_proc:stored_functions($csd_webconf:db),csr_proc:stored_updating_functions($csd_webconf:db))
	    let $urn:= string($function/@urn)
	    return <string key="{$urn}">{$csd_webconf:baseurl}CSD/csr/{$name}/careServicesRequest/{$urn}</string>
	  }
	</map>
      </map>
    }
  </map>
};



declare function page:services_menu($name) {
  <ul> 
    {if (not(csd_dm:document_source_exists($csd_webconf:db,$name))) then
    <li><a href="/CSD/initSampleDirectory/directory/{$name}/load">Initialize </a> {$name} </li>
  else 
    (
    <li><a href="/CSD/initSampleDirectory/directory/{$name}/get">Get </a> {$name}</li>,
    <li><a href="/CSD/initSampleDirectory/directory/{$name}/reload">Reload </a>{$name}</li>
  )
    }
  </ul>
};




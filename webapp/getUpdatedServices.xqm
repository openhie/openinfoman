module namespace page = 'http://basex.org/modules/web-page';

import module namespace csd_qus = "https://github.com/openhie/openinfoman/csd_qus";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace csd_webui =  "https://github.com/openhie/openinfoman/csd_webui";

declare namespace soap = "http://www.w3.org/2003/05/soap-envelope";


declare variable $page:csd_docs := csd_dm:registered_documents();



declare
  %rest:path("/CSD/getUpdatedServices/{$name}/soap")
  %rest:query-param("mtime", "{$mtime}")
  %rest:GET
  function page:updated_service_soap($name,$mtime)
{ 
 let $url := csd_webui:generateURL(("CSD/getUpdatedServices/" , $name , "/get"))
 return (
 <rest:response>
   <http:response status="200" >
     <http:header name="Content-Type" value="application/soap+xml"/>
     <http:header name="Content-Disposition"  value="inline; filename=soap_query_updated_services_{$name}.xml"/>
   </http:response>
   </rest:response>
   ,
   csd_qus:create_last_update_request($url,$mtime)
 )
 
};


declare
  %rest:path("/CSD/getUpdatedServices/{$name}/get")
  %rest:consumes("application/xml", "text/xml", "application/soap+xml")
  %rest:POST("{$updatedServicesRequest}")
  function page:updated_services($name,$updatedServicesRequest) 
{ 
if (csd_dm:document_source_exists($name)) then 
  (
  <rest:response>
    <http:response status="200" >
      <http:header name="Content-Type" value="application/soap+xml"/>
      <http:header name="Content-Disposition"  value="inline; filename=response_query_updated_services_{$name}.xml"/>
    </http:response>
  </rest:response>
  ,
  csd_qus:get_updated_services_soap($updatedServicesRequest/soap:Envelope,csd_dm:open_document($name))
 							  
  )
else 
  ()
};


declare
  %rest:path("/CSD/getUpdatedServices")
  %rest:GET
  %output:method("xhtml")
  function page:updated_services_list() 
{ 
let $response := 
  <span>
    <h2>Get Updated Services For Sample And Merged Directories</h2>
    <ul>
      {
	for $name in $page:csd_docs
	return 	<li>
	<h3>Service Directory:<a href="{csd_webui:generateURL(('CSD/getUpdatedServices',$name))}">{$name}</a></h3>
	  {page:service_menu($name)}
	</li>
      }
    </ul>
  </span>
  return page:wrapper($response)
};

declare
  %rest:path("/CSD/getUpdatedServices/{$name}")
  %rest:GET
  %output:method("xhtml")
function page:show_service_menu($name) {
  page:wrapper(<span><h3>{$name}</h3>{page:service_menu($name)}</span>)
};


declare function page:service_menu($name) 
{
  <span>
    <ul>
    <li>
    Query {$name} for Updated Services by time
    <form method='get' action="{csd_webui:generateURL(('/CSD/getUpdatedServices',$name,'get'))}">
      <input  size="35" id="datetimepicker_{$name}"    name='mtime' type="text" value=""/>   
      <input type='submit' />
    </form> 
    </li>
    <li>
    Get {$name}'s SOAP reuest for Query for Updated Services by time
    <form method='get' action="{csd_webui:generateURL(('/CSD/getUpdatedServices',$name,'soap'))}">
      <input  size="35" id="soap_datetimepicker_{$name}"  name='mtime' type="text" value=""/>   
      <input type='submit' />
    </form> 
    </li>
    Submit {$name} SOAP request to:
    <pre>{csd_webui:generateURL(('CSD/getUpdatedServices/',$name,'/get'))}</pre> 

    </ul>
  </span>
};

declare function page:wrapper($response) {
 let $headers := (
    <link rel="stylesheet" type="text/css" media="screen"   href="{csd_webui:generateURL('static/bootstrap-datetimepicker/css/bootstrap-datetimepicker.min.css')}"/>
    ,<script src="{csd_webui:generateURL('static/bootstrap-datetimepicker/js/bootstrap-datetimepicker.js')}"/>
    ,<script type="text/javascript">
    $( document ).ready(function() {{ 
      {
	for $name in $page:csd_docs	
	return (
	  concat("$('#datetimepicker_",$name,"').datetimepicker({format: 'yyyy-mm-ddThh:ii:ss+00:00',startDate:'2013-10-01'});")
	  ,concat("$('#soap_datetimepicker_",$name,"').datetimepicker({format: 'yyyy-mm-ddThh:ii:ss+00:00',startDate:'2013-10-01'}); ")
	)
      }
    }});
    </script>
    
   )
 return csd_webui:wrapper($response,$headers)
};
   
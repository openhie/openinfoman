module namespace page = 'http://basex.org/modules/web-page';

import module namespace csd_qus = "https://github.com/his-interop/openinfoman/csd_qus" at "../repo/csd_query_updated_services.xqm";
import module namespace csd_dm = "https://github.com/his-interop/openinfoman/csd_dm" at "../repo/csd_document_manager.xqm";
import module namespace csd_webconf =  "https://github.com/his-interop/openinfoman/csd_webconf" at "../repo/csd_webapp_config.xqm";

import module namespace file = "http://expath.org/ns/file";
declare namespace soap = "http://www.w3.org/2003/05/soap-envelope";


declare variable $page:csd_docs := csd_dm:registered_documents($csd_webconf:db);



declare
  %rest:path("/CSD/getUpdatedServices/{$name}/soap")
  %rest:consumes("application/xml", "text/xml", "multipart/form-data")
  %rest:query-param("mtime", "{$mtime}")
  %rest:GET
  function page:updated_service_soap($name,$mtime)
{ 
 let $url := concat($csd_webconf:baseurl,"CSD/getUpdatedServices/" , $name , "/get")
 return (
 <rest:response>
   <http:response status="200" >
     <http:header name="Content-Type" value="text/xml; charset=utf-8"/>
     <http:header name="Content-Disposition"  value="inline; filename=soap_query_updated_services_{$name}"/>
   </http:response>
   </rest:response>
   ,
   csd_qus:create_last_update_request($url,$mtime)
 )
 
};


declare
  %rest:path("/CSD/getUpdatedServices/{$name}/get")
  %rest:consumes("application/xml", "text/xml", "multipart/form-data")
  %rest:POST("{$updatedServicesRequest}")
  function page:updated_services($name,$updatedServicesRequest) 
{ 
if (csd_dm:document_source_exists($csd_webconf:db,$name)) then 
   csd_qus:get_updated_services_soap($updatedServicesRequest/soap:Envelope,csd_dm:open_document($csd_webconf:db,$name))   
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
	<h3>Service Directory:<a href="/CSD/getUpdatedServices/{$name}">{$name}</a></h3>
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
    <form method='get' action="/CSD/getUpdatedServices/{$name}/get">
      <input  size="35" id="datetimepicker_{$name}"    name='mtime' type="text" value=""/>   
      <input type='submit' />
    </form> 
    </li>
    <li>
    Get {$name}'s SOAP reuest for Query for Updated Services by time
    <form method='get' action="/CSD/getUpdatedServices/{$name}/soap">
      <input  size="35" id="soap_datetimepicker_{$name}"  name='mtime' type="text" value=""/>   
      <input type='submit' />
    </form> 
    </li>
    Submit {$name} SOAP request to:
    <pre>{$csd_webconf:baseurl}/CSD/getUpdatedServices/{$name}/get</pre> 

    </ul>
  </span>
};

declare function page:wrapper($response) {
 <html>
  <head>

    <link href="{$csd_webconf:baseurl}/static/bootstrap/css/bootstrap.css" rel="stylesheet"/>
    <link href="{$csd_webconf:baseurl}/static/bootstrap/css/bootstrap-theme.css" rel="stylesheet"/>
    

    <link rel="stylesheet" type="text/css" media="screen"   href="{$csd_webconf:baseurl}/static/bootstrap-datetimepicker/css/bootstrap-datetimepicker.min.css"/>

    <script src="https://code.jquery.com/jquery.js"/>
    <script src="{$csd_webconf:baseurl}/static/bootstrap/js/bootstrap.min.js"/>
    <link rel="stylesheet" type="text/css" media="screen"   href="{$csd_webconf:baseurl}/static/bootstrap-datetimepicker/css/bootstrap-datetimepicker.min.css"/>

    <script src="{$csd_webconf:baseurl}/static/bootstrap-datetimepicker/js/bootstrap-datetimepicker.js"/>
    <script type="text/javascript">
    $( document ).ready(function() {{
      {
	for $name in $page:csd_docs
	return (
	"$('#datetimepicker_",$name,"').datetimepicker({format: 'yyyy-mm-ddThh:ii:ss+00:00',startDate:'2013-10-01'});",
	"$('#soap_datetimepicker_",$name,"').datetimepicker({format: 'yyyy-mm-ddThh:ii:ss+00:00',startDate:'2013-10-01'}); ")
      }
    }});
    </script>
  </head>
  <body>  
    <div class="navbar navbar-inverse navbar-static-top">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="{$csd_webconf:baseurl}/CSD">OpenInfoMan</a>
        </div>
      </div>
    </div>
    <div class='container'>  {$response}</div>
  </body>
 </html>
};




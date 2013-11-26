module namespace page = 'http://basex.org/modules/web-page';

import module namespace csd_qus = "https://github.com/his-interop/openinfoman/csd_qus" at "../repo/csd_query_updated_services.xqm";
import module namespace csd_mcs = "https://github.com/his-interop/openinfoman/csd_mcs" at "../repo/csd_merge_cached_services.xqm";
import module namespace csd_lsd = "https://github.com/his-interop/openinfoman/csd_lsd" at "../repo/csd_load_sample_directories.xqm";
import module namespace request = "http://exquery.org/ns/request";

import module namespace file = "http://expath.org/ns/file";
declare namespace soap = "http://www.w3.org/2003/05/soap-envelope";


declare variable $page:db := 'provider_directory';
declare variable $page:csd_docs := ( $csd_mcs:merged_services_doc,csd_lsd:sample_directories());

declare
  %rest:path("/CSD/getUpdatedServices/{$name}/soap")
  %rest:consumes("application/xml", "text/xml", "multipart/form-data")
  %rest:query-param("mtime", "{$mtime}")
  %rest:GET
  function page:updated_service_soap($name,$mtime)
{ 
 let $url := concat(request:scheme(), "://",request:hostname(),":",request:port(),"/CSD/getUpdatedServices/" , $name , "/get")
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
  %rest:path("/CSD/getUpdateServices/{$name}/get")
  %rest:consumes("application/xml", "text/xml", "multipart/form-data")
  %rest:POST("{$updatedServicesRequest}")
  function page:updated_services($name,$updatedServicesRequest) 
{ 
for $doc in collection($page:db)
where( matches(document-uri($doc), $name) and $name = $page:csd_docs)
return csd_qus:get_updated_services_soap($updatedServicesRequest/soap:Envelope,$doc)   

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
	return 
	<li>
	  Service Directory: <b>{$name}</b>
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
	    <pre>{request:hostname()}:{request:port()}//CSD/getUpdatedServices/{$name}/get</pre> 

	  </ul>
	</li>
      }
    </ul>
  </span>
  return page:wrapper($response)
};


declare function page:wrapper($response) {
 <html>
  <head>

    <link href="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap/css/bootstrap.css" rel="stylesheet"/>
    <link href="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap/css/bootstrap-theme.css" rel="stylesheet"/>
    

    <link rel="stylesheet" type="text/css" media="screen"   href="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap-datetimepicker/css/bootstrap-datetimepicker.min.css"/>

    <script src="https://code.jquery.com/jquery.js"/>
    <script src="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap/js/bootstrap.min.js"/>
    <link rel="stylesheet" type="text/css" media="screen"   href="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap-datetimepicker/css/bootstrap-datetimepicker.min.css"/>

    <script src="https://code.jquery.com/jquery.js"/>
    <script src="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap/js/bootstrap.min.js"/>
    <script src="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap-datetimepicker/js/bootstrap-datetimepicker.js"/>
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
          <a class="navbar-brand" href="{request:scheme()}://{request:hostname()}:{request:port()}/CSD">OpenInfoMan</a>
        </div>
      </div>
    </div>
    {$response}
  </body>
 </html>
};




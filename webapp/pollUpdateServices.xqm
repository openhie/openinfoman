module namespace page = 'http://basex.org/modules/web-page';


import module namespace csd_psd = "https://github.com/his-interop/openinfoman/csd_psd" at "../repo/csd_poll_service_directories.xqm";
import module namespace csd_lsc = "https://github.com/his-interop/openinfoman/csd_lsc" at "../repo/csd_local_services_cache.xqm";
import module namespace request = "http://exquery.org/ns/request";
import module namespace csd_qus =  "https://github.com/his-interop/openinfoman/csd_qus" at "../repo/csd_query_updated_services.xqm";
declare variable $page:db := 'provider_directory';




declare
  %rest:path("/CSD/pollService/{$name}")
  %output:method("xhtml")
  %rest:GET
  function page:display_service_menu($name) 
{
  let $response :=     <div class='container'>
      <div class='row'>
 	<div class="col-md-8">
	{page:service_menu($name)}
	</div>
      </div>
    </div>
  return page:wrapper($response)
};


declare
  %rest:path("/CSD/pollService/{$name}/get")
  %rest:query-param("mtime", "{$mtime}")
  %rest:GET
  function page:poll_service($name,$mtime)
{ 
if ($mtime) then
 csd_psd:poll_service_directory_soap_response($name,$mtime)
else
 csd_psd:poll_service_directory_soap_response($name,csd_lsc:get_service_directory_mtime($page:db,$name))
};


declare
  %rest:path("/CSD/pollService/{$name}/get_csd")
  %rest:query-param("mtime", "{$mtime}")
  %rest:GET
  function page:poll_service_csd($name,$mtime)
{ 
if ($mtime) then
 csd_psd:poll_service_directory($name,$mtime)
else
 csd_psd:poll_service_directory($name,csd_lsc:get_service_directory_mtime($page:db,$name))
};

declare
  %rest:path("/CSD/pollService/{$name}/get_soap")
  %rest:query-param("mtime", "{$mtime}")
  %rest:GET
  function page:poll_service_soap($name,$mtime)
{ 
 let $url := csd_psd:get_service_directory_url($name)    
 return (
 <rest:response>
   <http:response status="200" >
     <http:header name="Content-Type" value="text/xml; charset=utf-8"/>
     <http:header name="Content-Disposition"  value="inline; filename=soap_query_updated_services_{$name}"/>
   </http:response>
   </rest:response>
   ,
   if ($mtime) then
     csd_qus:create_last_update_request($url,$mtime)
   else
     csd_qus:create_last_update_request($url,csd_lsc:get_service_directory_mtime($page:db,$name))
 )

};

declare function page:wrapper($response) {
 <html>
  <head>

    <link href="http://{request:hostname()}:{request:port()}/static/bootstrap/css/bootstrap.css" rel="stylesheet"/>
    <link href="http://{request:hostname()}:{request:port()}/static/bootstrap/css/bootstrap-theme.css" rel="stylesheet"/>
    

    <link rel="stylesheet" type="text/css" media="screen"   href="http://{request:hostname()}:{request:port()}/static/bootstrap-datetimepicker/css/bootstrap-datetimepicker.min.css"/>

    <script src="https://code.jquery.com/jquery.js"/>
    <script src="http://{request:hostname()}:{request:port()}/static/bootstrap/js/bootstrap.min.js"/>
    <script src="http://{request:hostname()}:{request:port()}/static/bootstrap-datetimepicker/js/bootstrap-datetimepicker.js"/>
    <script type="text/javascript">
    $( document ).ready(function() {{
      {
	let $services := csd_psd:get_services()
	for $name in $services 
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
          <a class="navbar-brand" href="http://{request:hostname()}:{request:port()}/CSD">OpenInfoMan</a>
        </div>
      </div>
    </div>
    {$response}
  </body>
 </html>
};



declare
  %rest:path("/CSD/pollService")
  %rest:GET
  %output:method("xhtml")
  function page:poll_service_list()
{ 
let $services := csd_psd:get_services()
let $response:=
  <div>
    <div class='container'>
      <div class='row'>
 	<div class="col-md-8">
	  <h2>Service Directories</h2>
	  <ul>
	    {for $name in $services
	    let $mtime := csd_lsc:get_service_directory_mtime($page:db,$name)
	    order by $name
	    return 
	    <li>
	      <b><a href="/CSD/pollService/{$name}">{$name}</a></b> last <a href="/CSD/cacheService/directory/{$name}">cached</a> on {$mtime}
	      <br/>
	      <b>Services:</b>  {page:service_menu($name)}
	    </li>
	    }
	  </ul>
	</div>
      </div>
    </div>
  </div>
  
return page:wrapper($response)

};

declare function page:service_menu($name) {
  let $url := csd_psd:get_service_directory_url($name)
  let $mtime := csd_lsc:get_service_directory_mtime($page:db,$name)
  return 
<span>
  <ul>
    <li><a href="/CSD/pollService/{$name}/get"> Query  {$name} for Updated Services using stored last modified time (SOAP result)</a> </li>
    <li><a href="/CSD/pollService/{$name}/get_csd"> Query  {$name} for Updated Services using stored last modified time (CSD result)</a> </li>
    <li><a href="/CSD/pollService/{$name}/get_soap"> Get {$name}'s Soap Query for Updated Services Request using stored last modified time</a>    </li>
    <li>
    Query {$name} for Updated Services by time
    <form method='get' action="/CSD/pollService/{$name}/get">
      <input  size="35" id="datetimepicker_{$name}"    name='mtime' type="text" value="{$mtime}"/>   
      <input type='submit' />
    </form> 
    </li>
    <li>
    Get {$name}'s SOAP reuest for Query for Updated Services by time
    <form method='get' action="/CSD/pollService/soap_query_updated_services_{$name}">
      <input  size="35" id="soap_datetimepicker_{$name}"  name='mtime' type="text" value="{$mtime}"/>   
      <input type='submit' />
    </form> 
    </li>

  </ul>
  To test submission on your machine you can do:
  <pre>curl --form "fileupload=@soap_query_updated_services_{$name}.xml" {$url}</pre>
  where soap_updated_services_{$name}.xml is  the downloaded soap request document
</span>
};  



module namespace page = 'http://basex.org/modules/web-page';


import module namespace csd_psd = "https://github.com/his-interop/openinfoman/csd_psd" at "../repo/csd_poll_service_directories.xqm";
import module namespace csd_lsc = "https://github.com/his-interop/openinfoman/csd_lsc" at "../repo/csd_local_services_cache.xqm";
import module namespace request = "http://exquery.org/ns/request";
import module namespace csd_qus =  "https://github.com/his-interop/openinfoman/csd_qus" at "../repo/csd_query_updated_services.xqm";
declare variable $page:collection := collection('provider_directory')[1];
declare
  %rest:path("/CSD/pollService/get/{$name}")
  %rest:query-param("mtime", "{$mtime}")
  %rest:GET
  function page:poll_service($name,$mtime)
{ 
if ($mtime) then
 csd_psd:poll_service_directory_soap_response($name,$mtime)
else
 csd_psd:poll_service_directory_soap_response($name,csd_lsc:get_service_directory_mtime($page:collection,$name))
};

declare
  %rest:path("/CSD/pollService/get_soap/{$name}")
  %rest:query-param("mtime", "{$mtime}")
  %rest:GET
  function page:poll_service_soap($name,$mtime)
{ 
 if ($mtime) then
   csd_qus:create_last_update_request($mtime)
 else
  csd_qus:create_last_update_request(csd_lsc:get_service_directory_mtime($page:collection,$name))
};


declare updating
  %rest:path("/CSD/pollService/init_cache_meta")
  %rest:GET
  function page:init_cache_meta()
{
  csd_lsc:init_cache_meta($page:collection)
};

declare
  %rest:path("/CSD/pollService/cache_meta")
  %rest:GET
  function page:get_cache_meta()
{
  csd_lsc:get_cache_data($page:collection,())
};
declare
  %rest:path("/CSD/pollService/cache_meta/{$name}")
  %rest:GET
  function page:get_service_cache_meta($name)
{
  csd_lsc:get_cache_data($page:collection,$name)
};
declare updating
  %rest:path("/CSD/pollService/drop_cache_meta/{$name}")
  %rest:GET
  function page:drop_service_cache_meta($name)
{
  csd_lsc:drop_cache_data($page:collection,$name)
};

declare
  %rest:path("/CSD/pollService/get_cache/{$name}")
  %rest:GET
  function page:get_cache($name)
{ 
 csd_lsc:get_cache($page:collection,$name) 
};

declare updating
  %rest:path("/CSD/pollService/empty_cache/{$name}")
  %rest:GET
  function page:empty_cache($name)
{ 
 csd_lsc:empty_cache($page:collection,$name) 
};


declare updating
  %rest:path("/CSD/pollService/update_cache/{$name}")
  %rest:GET
  function page:update_cache($name)
{ 
 csd_lsc:update_cache($page:collection,$name) 
};



declare
  %rest:path("/CSD/pollService")
  %rest:GET
  %output:method("xhtml")
  function page:poll_service_list()
{ 
let $services := csd_psd:get_services()
return
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
      {for $name in $services 
      return (
	"$('#datetimepicker_",$name,"').datetimepicker({format: 'yyyy-mm-ddThh:ii:ss+00:00',startDate:'2013-10-01'});",
	"$('#soap_datetimepicker_",$name,"').datetimepicker({format: 'yyyy-mm-ddThh:ii:ss+00:00',startDate:'2013-10-01'}); ")
      }
    }});
    </script>
  </head>
  <body>  
    <div class="navbar navbar-inverse navbar-fixed-top">
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

    <div class='container'>
      <div class='row'>
 	<div class="col-md-8">
	  <h2>Global Operations</h2>
	  <ul>
	    <li>Get <a href="http://{request:hostname()}:{request:port()}/CSD/pollService/cache_meta">Cache Meta-Data</a></li>
	  </ul>
	</div>
      </div>
      <div class='row'>
 	<div class="col-md-8">
	  <h2>Service Directories</h2>
	  <ul>
	    {for $name in $services
	    let $url := csd_psd:get_service_directory_url($name)
	    let $mtime := csd_lsc:get_service_directory_mtime($page:collection,$name)
	    order by $name
	    return 
	    <li>
	      <b>{$name} last polled on {$mtime}</b>:
	      <ul>
		<li><a href="/CSD/pollService/empty_cache/{$name}">Empty</a> local cache</li>
		<li><a href="/CSD/pollService/get_cache/{$name}">Get</a> local cache</li>
		<li><a href="/CSD/pollService/update_cache/{$name}">Update</a> local cache</li>
		<li><a href="/CSD/pollService/cache_meta/{$name}">Get Cache Meta Data</a></li>
		<li><a href="/CSD/pollService/drop_cache_meta/{$name}">Drop Chache Meta Data</a></li>
		<li><a href="/CSD/pollService/get/{$name}"> Query for Updated Services using stored last modified time</a> </li>
		<li><a href="/CSD/pollService/get_soap/{$name}"> Get Soap Query for Updated Services Request using stored last modified time</a>    </li>
		<li>
	        Query for Updated Services by time
		<form method='get' action="/CSD/pollService/get/{$name}">
	          <input  size="35" id="datetimepicker_{$name}"    name='mtime' type="text" value="{$mtime}"/>   
		  <input type='submit' />
		</form> 
		</li>
		<li>
	        Get SOAP reuest for Query for Updated Services by time
		<form method='get' action="/CSD/pollService/get_soap/{$name}">
	          <input  size="35" id="soap_datetimepicker_{$name}"  name='mtime' type="text" value="{$mtime}"/>   
		  <input type='submit' />
		</form> 
		</li>

	      </ul>
	      To test submission on your machine you can do:
	      <pre>
	      curl --form "fileupload=@soap.xml" {$url}
	      </pre>
	      where soap.xml is  the downloaded soap request document
		
	    </li>
	    }
	  </ul>
	</div>
      </div>
    </div>
  </body>
</html>

};

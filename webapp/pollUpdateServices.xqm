module namespace page = 'http://basex.org/modules/web-page';


import module namespace csd_psd = "https://github.com/his-interop/openinfoman/csd_psd" at "../repo/csd_poll_service_directories.xqm";
import module namespace request = "http://exquery.org/ns/request";


declare
  %rest:path("/CSD/pollService/get/{$name}")
  %rest:query-param("mtime", "{$mtime}")
  %rest:GET
  function page:poll_service($name,$mtime)
{ 
 csd_psd:poll_service_directory($name,$mtime)
};

declare
  %rest:path("/CSD/pollService/get_soap/{$name}")
  %rest:query-param("mtime", "{$mtime}")
  %rest:GET
  function page:poll_service_soap($name,$mtime)
{ 
 csd_psd:get_service_directory_soap_request($name,$mtime)
};



declare
  %rest:path("/CSD/pollService")
  %rest:GET
  %output:method("xhtml")
  function page:poll_service_list()
{ 
let $services := csd_psd:get_services()
return <html>
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
	<h2>Service Directories</h2>
	<ul>
	  {for $name in $services
	  let $url := csd_psd:get_service_directory_url($name)
	  let $mtime := csd_psd:get_service_directory_mtime($name)
	  order by $name
	  return 
	  <li>
	    <b>{$name} last polled on {$mtime}</b>:
	    <ul>
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
  </body>
</html>

};

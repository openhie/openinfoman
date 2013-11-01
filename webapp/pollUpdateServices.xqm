module namespace page = 'http://basex.org/modules/web-page';


import module namespace csd_psd = "https://github.com/his-interop/openinfoman/csd_psd" at "../repo/csd_poll_service_directories.xqm";
import module namespace request = "http://exquery.org/ns/request";


declare
  %rest:path("/CSD/pollService/get/{$name}")
  %rest:GET
  function page:poll_service($name)
{ 
 csd_psd:poll_service_directory($name)
};

declare
  %rest:path("/CSD/pollService/get_soap/{$name}")
  %rest:GET
  function page:poll_service_soap($name)
{ 
 csd_psd:get_service_directory_soap_request($name)
};



declare
  %rest:path("/CSD/pollService")
  %rest:GET
  %output:method("xhtml")
  function page:poll_service_list()
{ 
<html>
  <head>
    <link href="http://{request:hostname()}:{request:port()}/static/bootstrap/css/bootstrap.css" rel="stylesheet"/>
    <link href="http://{request:hostname()}:{request:port()}/static/bootstrap/css/bootstrap-theme.css" rel="stylesheet"/>
    <link rel="stylesheet" type="text/css" media="screen"   href="http://{request:hostname()}:{request:port()}/static/bootstrap-datetimepicker.min.css"/>
    <script src="https://code.jquery.com/jquery.js"></script>
    <script src="js/bootstrap.min.js"></script>
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
    <div class='containter'>
      <div class='row'>
	<h2>Service Directories</h2>
	<ul>
	  {for $name in csd_psd:get_services()
	  let $url := csd_psd:get_service_directory_url($name)
	  order by $name
	  return 
	  <li>
	    <b>{$name}</b>:
	    <ul>
	      <li><a href="/CSD/pollService/get/{$name}"> Query for Updated Services</a> </li>
	      <li><a href="/CSD/pollService/get_soap/{$name}"> Get Soap Query for Updated Services Request</a>    </li>

	    </ul>
	    To test submission on your machine you can do:
	    <pre>
	    curl --form "fileupload=@soap.xml" {$url}
	    </pre>
	    or 
	    <pre>
	    curl -X POST -d @soap.xml {$url}
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

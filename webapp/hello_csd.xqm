module namespace page = 'http://basex.org/modules/web-page';


import module namespace csd_psd = "https://github.com/his-interop/openinfoman/csd_psd" at "../repo/csd_poll_service_directories.xqm";
import module namespace request = "http://exquery.org/ns/request";

declare
  %rest:path("/CSD")
  %rest:GET
  %output:method("xhtml")

  function page:list_functionality()
{ 
<html>
  <head>
    <link href="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap/css/bootstrap.css" rel="stylesheet"/>
    <link href="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap/css/bootstrap-theme.css" rel="stylesheet"/>
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
          <a class="navbar-brand" href="{request:scheme()}://{request:hostname()}:{request:port()}/CSD">OpenInfoMan</a>
        </div>
      </div>
    </div>
    <div class="jumbotron">
      <div class="container">
	<h2>Welcome to OpenInfoMan</h2>
	<b>OpenInfoMan</b> is XQuery and RESTXQ based implementation of the Care Services Directory (<a href="ftp://ftp.ihe.net/DocumentPublication/CurrentPublished/ITInfrastructure/IHE_ITI_Suppl_CSD.pdf">CSD</a>) profile from <a href="http://ihe.net">IHE</a> which implements the following actors and transactions:
	<ul>
	  <li>
	    <i>Info Manager</i> : 
	    <div style="padding-left:9em;margin-top:-2.1em;">
	    Find Matching Services (Ad-Hoc and Stored) [ITI-73]<br/>
	    Query for  Updated Services Transaction [ITI-74]
	    </div>
	  </li>
	  <li>
	    <i>Services Directory</i> : 
	    <div style="padding-left:9em;margin-top:-2.1em;">Query for  Updated Services Transaction [ITI-74]</div>
	</li>

	</ul>
      </div>
    </div>
    <div class="container">
      <div class='row'>
	<div class="col-md-4">
	  <p><b>OpenInfoMan</b> has been developed as part of <a href="http://ohie.net">OpenHIE</a> and is intended to be the engine behind the CSD compliant <a href="https://wiki.ohie.org/display/SUB/Provider+Registry+Community">Provider Registry</a> and to be incorporated in <a href="http://openhim">OpenHIM</a>.  
	  
	  Source code is on <a href="https://github.com/his-interop/openinfoman">github</a>
	  </p>
      	</div>
	<div class="col-md-6">
	
	  <p>These the top-level endpoints are exposed</p>
	  <ul>
	    <li>Endpoint for submitting careServiceRequest documents <i>{request:scheme()}://{request:hostname()}:{request:port()}/CSD/careServiceRequest</i></li>
	    <li><a href="{request:scheme()}://{request:hostname()}:{request:port()}/CSD/initSampleDirectory">Initialize Sample Directories </a></li>
	    <li><a href="{request:scheme()}://{request:hostname()}:{request:port()}/CSD/getUpdatedServices">Endpoints for submitting getUpdatedServices soap request </a></li>
	    <li><a href="{request:scheme()}://{request:hostname()}:{request:port()}/CSD/pollService">poll registered service directories </a></li>
	    <li><a href="{request:scheme()}://{request:hostname()}:{request:port()}/CSD/cacheService">administer local cache of registered service directories </a></li>
	    <li><a href="{request:scheme()}://{request:hostname()}:{request:port()}/CSD/mergeServices">merge caches or registered services directories </a></li>
	    <li><a href="{request:scheme()}://{request:hostname()}:{request:port()}/CSD/test">list of test careServiceRequests </a></li>
	  </ul>
	</div>
      </div>
    </div>
    <div class="footer">
      <div class="container">
	<div class='row'>
	  <div class="col-md-12">
	    <a class='pull-right' href="http://www.youtube.com/watch?v=pBjvkHHuPHc"  style='color:rgb(0,0,0);text-decoration:none'>(tra-la-la)</a>
	  </div>
	</div>
      </div>
    </div>
  </body>
</html>
};


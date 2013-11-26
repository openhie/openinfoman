module namespace page = 'http://basex.org/modules/web-page';


import module namespace csd_dm = "https://github.com/his-interop/openinfoman/csd_dm" at "../repo/csd_document_manager.xqm";
import module namespace request = "http://exquery.org/ns/request";

declare variable $page:db := 'provider_directory';

declare updating
  %rest:path("/CSD/initDocumentManager")
  %rest:GET
  function page:init_dm()
{ 
(csd_dm:init($page:db),
db:output(page:redirect(concat(request:scheme(),"://",request:hostname(),":",request:port(),"/CSD")))
)
};

declare function page:redirect($redirect as xs:string) as element(restxq:redirect)
{
  <restxq:redirect>{ $redirect }</restxq:redirect>
};


declare
  %rest:path("/CSD")
  %rest:GET
  %output:method("xhtml")
  function page:list_functionality()
{ 
let $what_is_dm :=   
<p>
  The document manger registers documents to perform  careServicesRequests and getUpdatedServices requests  against.  Registered documents can be any of:
  <ul>
    <li>Local cache of a remote service directory -- this is useful for turning a Care Services Directory into an Open Info Manager</li>
    <li>Sample Directories -- these loaded from an XML source file on the system and are useful for testing</li>
    <li>The merged result of remote service directories</li>
  </ul>
</p>
let $response := if (not(csd_dm:dm_exists($page:db))) then
 <span>
   <h3>No Document Manager Exists</h3>
   <p>Please <a href="/CSD/initDocumentManager">initialize the document manager</a></p> 
   Please make sure you have created the database {$page:db}!
   {$what_is_dm}
 </span>
else 
<span>       
  {$what_is_dm}
  <p>
    {let $docs := csd_dm:registered_documents($page:db)  
    return ( "You have ", count($docs) , " registered document(s) available: ", <b> {string-join($docs,", ")}</b> )
    }
  </p>
  <p>These the top-level endpoints are exposed</p>
  <ul>
    <li><a href="{request:scheme()}://{request:hostname()}:{request:port()}/CSD/initSampleDirectory">Initialize Sample Directories </a></li>
    <li><a href="{request:scheme()}://{request:hostname()}:{request:port()}/CSD/csr">Care Services Request </a></li>
    <li><a href="{request:scheme()}://{request:hostname()}:{request:port()}/CSD/getUpdatedServices">Endpoints for submitting getUpdatedServices soap request </a></li>
    <li><a href="{request:scheme()}://{request:hostname()}:{request:port()}/CSD/pollService">poll registered service directories </a></li>
    <li><a href="{request:scheme()}://{request:hostname()}:{request:port()}/CSD/cacheService">administer local cache of registered service directories </a></li>
    <li><a href="{request:scheme()}://{request:hostname()}:{request:port()}/CSD/mergeServices">merge caches or registered services directories </a></li>
    <li><a href="{request:scheme()}://{request:hostname()}:{request:port()}/CSD/test">list of test careServiceRequests </a></li>
  </ul>
</span>
return page:nocache(page:wrapper($response))
};



declare function page:nocache($response) {
(<http:response status="200" message="OK">  
  <http:header name="Cache-Control" value="must-revalidate,no-cache,no-store"/>
</http:response>,
$response)
};


declare function page:wrapper($response) {
<html>
  <head>

    <link href="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap/css/bootstrap.css" rel="stylesheet"/>
    <link href="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap/css/bootstrap-theme.css" rel="stylesheet"/>
    

    <link rel="stylesheet" type="text/css" media="screen"   href="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap-datetimepicker/css/bootstrap-datetimepicker.min.css"/>

    <script src="https://code.jquery.com/jquery.js"/>
    <script src="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap/js/bootstrap.min.js"/>
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
	  {$response}
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



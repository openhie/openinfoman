module namespace page = 'http://basex.org/modules/web-page';


import module namespace csd_dm = "https://github.com/his-interop/openinfoman/csd_dm";
import module namespace csd_webconf =  "https://github.com/his-interop/openinfoman/csd_webconf";




declare updating
  %rest:path("/CSD/initDocumentManager")
  %rest:GET
  function page:init_dm()
{ 
(
csd_dm:init($csd_webconf:db),
db:output(page:redirect(concat($csd_webconf:baseurl,"CSD")))
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
if (not(csd_dm:dm_exists($csd_webconf:db))) then 
  page:redirect(concat($csd_webconf:baseurl,"CSD/initDocumentManager"))
else
  let $what_is_dm :=   
  <p>
    The document manger registers documents to perform  careServicesRequests and getUpdatedServices requests  against.  Registered documents can be any of:
    <ul>
      <li>Local cache of a remote service directory -- this is useful for turning a Care Services Directory into an Open Info Manager</li>
      <li>Sample Directories -- these loaded from an XML source file on the system and are useful for testing</li>
      <li>The merged result of remote service directories</li>
    </ul>
  </p>
  let $csd := 
  <span>       
    {$what_is_dm}
    <p>
      {let $docs := csd_dm:registered_documents($csd_webconf:db)  
      return ( "You have ", count($docs) , " registered document(s) available: ", <b> {string-join($docs,", ")}</b> )
      }
    </p>
    <p>These the top-level endpoints are exposed</p>
    <ul>
      <li><a href="{$csd_webconf:baseurl}CSD/storedFunctions">Manage Stored Functions</a></li>
      <li><a href="{$csd_webconf:baseurl}CSD/initSampleDirectory">Load and Register Sample Service Directories</a></li>
      <li><a href="{$csd_webconf:baseurl}CSD/pollService">Register and Poll Remote Service Service directories </a></li>
      <li><a href="{$csd_webconf:baseurl}CSD/cacheService">Administer local cache of registered service directories</a></li>
      <li><a href="{$csd_webconf:baseurl}CSD/mergeServices">Merge registered documents</a></li>
      <li><a href="{$csd_webconf:baseurl}CSD/csr">Execute Ad-Hoc Care Services Requests and View Care Service Request Endpoints for Registered Documents</a></li>
      <li><a href="{$csd_webconf:baseurl}CSD/getUpdatedServices">Endpoints for submitting getUpdatedServices Soap Request for Registered Documents</a></li>
      <li><a href="{$csd_webconf:baseurl}CSD/test">Execute test careServiceRequests against Registered Documents</a></li>
    </ul>
  </span>
  let $svs :=
  <span>
    In addition, there is some initial support for use of terminologies using the Sharing Value Sets(<a href="ftp://ftp.ihe.net/DocumentPublication/CurrentPublished/ITInfrastructure/IHE_ITI_Suppl_SVS_Rev2.1_TI_2010-08-10.pdf">SVS</a>) profile from IHE:
    <ul>
      <li><a href="{$csd_webconf:baseurl}CSD/SVS/initSampleSharedValueSet">load sample Shared Value Sets </a></li>
    </ul>
  </span>
  return page:nocache(page:wrapper($csd,$svs))
};



declare function page:nocache($response) {
(<http:response status="200" message="OK">  
  <http:header name="Cache-Control" value="must-revalidate,no-cache,no-store"/>
</http:response>,
$response)
};


declare function page:wrapper($csd,$svs) {
  let $generic := 
  <span>
    <p><b>OpenInfoMan</b> has been developed as part of <a href="http://ohie.net">OpenHIE</a> and is intended to be the engine behind the CSD compliant <a href="https://wiki.ohie.org/display/SUB/Provider+Registry+Community">Provider Registry</a> and to be incorporated in <a href="http://openhim">OpenHIM</a>.  
    
    Source code is on <a href="https://github.com/his-interop/openinfoman">github</a>
    </p>
  </span>

  return <html>
  <head>

    <link href="{$csd_webconf:baseurl}static/bootstrap/css/bootstrap.css" rel="stylesheet"/>
    <link href="{$csd_webconf:baseurl}static/bootstrap/css/bootstrap-theme.css" rel="stylesheet"/>
    

    <link rel="stylesheet" type="text/css" media="screen"   href="{$csd_webconf:baseurl}static/bootstrap/js/tab.js"/>

    <script src="https://code.jquery.com/jquery.js"/>
    <script src="{$csd_webconf:baseurl}static/bootstrap/js/bootstrap.min.js"/>
   <script type="text/javascript">
    $( document ).ready(function() {{
      $('#tab_csd a').click(function (e) {{
	e.preventDefault()
	$(this).tab('show')
      }});
      $('#tab_home a').click(function (e) {{
	e.preventDefault()
	$(this).tab('show')
      }});
      $('#tab_svs a').click(function (e) {{
	e.preventDefault()
	$(this).tab('show')
      }});
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
          <a class="navbar-brand" href="{$csd_webconf:baseurl}CSD">OpenInfoMan</a>
        </div>
      </div>
    </div>
    <div class="container">
      <ul class="nav nav-tabs">
	<li id='tab_home' class="active"><a  href="#home">Introduction</a></li>
	<li id='tab_csd'><a  href="#csd">CSD Endpoints</a></li>
	<li id='tab_svs'><a  href="#svs">SVS Endpoints</a></li>
      </ul>
      <div class="tab-content panel">
	<div class="tab-pane active panel-body" id="home">
	  <div class="jumbotron">

	    <div class='row'>
	      <div class="col-md-8">
		<h2>Welcome to OpenInfoMan</h2>
		<p>
		  <b>OpenInfoMan</b> is an XQuery and RESTXQ based implementation of the Care Services Directory (<a href="ftp://ftp.ihe.net/DocumentPublication/CurrentPublished/ITInfrastructure/IHE_ITI_Suppl_CSD.pdf">CSD</a>) profile from <a href="http://ihe.net">IHE</a> which implements the following actors and transactions:
		</p>
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
	      <div class="col-md-4">
		{$generic}
	      </div>
	    </div>
	  </div>
	</div>
	<div class="tab-pane panel-body" id="csd">
	  <div class='row'>
	    <div class="col-md-4">
	      {$generic}
	    </div>
	    <div class="col-md-6">
	      {$csd}
	    </div>
	  </div>
	</div>
	<div class="tab-pane panel-body" id="svs">
	  <div class='row'>
	    <div class="col-md-4">
	      {$generic}
	    </div>
	    <div class="col-md-6">
	      {$svs}
	    </div>
	  </div>
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



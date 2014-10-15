module namespace page = 'http://basex.org/modules/web-page';


import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";




declare function page:redirect($redirect as xs:string) as element(restxq:redirect)
{
  <restxq:redirect>{ $redirect }</restxq:redirect>
};



declare updating
  %rest:path("/CSD/createDirectory")
  %rest:POST
  %rest:form-param("directory","{$directory}")
  %output:method("xhtml")
  function page:create_directory($directory)
{ 
   (
     if (not (csd_dm:document_source_exists($csd_webconf:db,$directory))) then
       csd_dm:empty($csd_webconf:db,$directory) 
     else ()
     ,
   db:output(page:redirect(concat($csd_webconf:baseurl,"CSD")))
  )
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
  let $csd := 
  <span class='csd'>       
    {$what_is_dm}
    <p>
      {let $docs := csd_dm:registered_documents($csd_webconf:db)  
      return ( 
	  "You have ", count($docs) , " registered document(s) available: ", 
	  <ul>
	    {
	      for $doc in $docs 
	      return  
	      <li>
		<a href="{$csd_webconf:baseurl}CSD/getDirectory/{$doc}"> {$doc} </a>
		 [ 
		  <a class='text-warning' href="{$csd_webconf:baseurl}CSD/emptyDirectory/{$doc}" onclick="Empty confirm('Delete all the data in {$doc}?');"> Empty </a> 
		  / <a class='text-warning' href="{$csd_webconf:baseurl}CSD/deleteDirectory/{$doc}" onclick="return confirm('Delete all the data in {$doc}?');"> Delete </a> 
		  ]
	      </li>
	    }
	  </ul>
	  )
      }
    </p>
    <div>
      <h2>Create Blank Directory</h2>
      <form method='post' action="/CSD/createDirectory">
	<input name='directory' type='text'/>
	<input type='submit' value='Create'/>
      </form>
    </div>
  </span>
  let $svs :=
  <span class='svs'>
    In addition, there is some initial support for use of terminologies using the Sharing Value Sets(<a href="ftp://ftp.ihe.net/DocumentPublication/CurrentPublished/ITInfrastructure/IHE_ITI_Suppl_SVS_Rev2.1_TI_2010-08-10.pdf">SVS</a>) profile from IHE:
    <ul>
      <li><a href="{$csd_webconf:baseurl}CSD/SVS/initSampleSharedValueSet">load sample Shared Value Sets </a></li>
    </ul>
  </span>
  let $adapters := 
    <span class='adapters'>
      List of all adapters installed: <a href="{$csd_webconf:baseurl}CSD/adapter">CSD Adapters</a>      
    </span>
  let $generic := 
    <span>
    <p>These the top-level endpoints are exposed</p>
    <ul>
      <li><a href="{$csd_webconf:baseurl}CSD/storedFunctions">Manage Stored Functions</a></li>
      <li><a href="{$csd_webconf:baseurl}CSD/initSampleDirectory">Load and Register Sample Service Directories</a></li>
      <li><a href="{$csd_webconf:baseurl}CSD/pollService">Register and Poll Remote Service Service directories </a></li>
      <li><a href="{$csd_webconf:baseurl}CSD/csr">Execute Ad-Hoc Care Services Requests and View Care Service Request Endpoints for Registered Documents</a></li>
      <li><a href="{$csd_webconf:baseurl}CSD/getUpdatedServices">Endpoints for submitting getUpdatedServices Soap Request for Registered Documents</a></li>
    </ul>
    </span>
  return page:nocache(page:wrapper($csd,$svs,$adapters,$generic))
};



declare function page:nocache($response) {
(<http:response status="200" message="OK">  
  <http:header name="Cache-Control" value="must-revalidate,no-cache,no-store"/>
</http:response>,
$response)
};


declare
  %rest:path("/CSD/getDirectory/{$name}")
  %rest:GET
  function page:get_directory($name)
{
  csd_dm:open_document($csd_webconf:db,$name) 
};

declare updating
  %rest:path("/CSD/emptyDirectory/{$name}")
  %rest:GET
  function page:empty_directory($name)
{
  (
    csd_dm:empty($csd_webconf:db,$name) 
    ,db:output(page:redirect(concat($csd_webconf:baseurl,"CSD")))
  )
};

declare updating
  %rest:path("/CSD/deleteDirectory/{$name}")
  %rest:GET
  function page:delete_directory($name)
{
  (
    csd_dm:delete($csd_webconf:db,$name) 
    ,db:output(page:redirect(concat($csd_webconf:baseurl,"CSD")))
  )
};


declare function page:wrapper($csd,$svs,$adapters) {
  page:wrapper($csd,$svs,$adapters,()) 
};

declare function page:wrapper($csd,$svs,$adapters,$generic_csd) {
  let $generic := 
  <span>
    <p><b>OpenInfoMan</b> has been developed as part of <a href="http://ohie.net">OpenHIE</a> and is intended to be the engine behind the CSD compliant <a href="https://wiki.ohie.org/display/SUB/Provider+Registry+Community">Provider Registry</a> and to be incorporated in <a href="http://openhim">OpenHIM</a>.  
    
    Source code is on <a href="https://github.com/openhie/openinfoman">github</a>
    </p>
  </span>

  let $headers :=  (
    <link rel="stylesheet" type="text/css" media="screen"   href="{$csd_webconf:baseurl}static/bootstrap/js/tab.js"/>  
    ,<script type="text/javascript">
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
      $('#tab_adapters a').click(function (e) {{
	e.preventDefault()
	$(this).tab('show')
      }});
    }});
    </script>

    )
    let $content := (
      <ul class="nav nav-tabs">
	<li id='tab_home' class="active"><a  href="#home">Introduction</a></li>
	<li id='tab_csd'><a  href="#csd">CSD Endpoints</a></li>
	<li id='tab_svs'><a  href="#svs">SVS Endpoints</a></li>
	<li id='tab_adapters'><a  href="#adapters">CSD Adapters</a></li>
      </ul>
      ,<div class="tab-content panel">
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
	      {$generic_csd}
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
	<div class="tab-pane panel-body" id="adapters">
	  <div class='row'>
	    <div class="col-md-4">
	      {$generic}
	    </div>
	    <div class="col-md-6">
	      {$adapters}
	    </div>
	  </div>
	</div>
      </div>
      )

  return csd_webconf:wrapper($content,$headers)
};



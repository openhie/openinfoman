module namespace page = 'http://basex.org/modules/web-page';

import module namespace csr_proc = "https://github.com/his-interop/openinfoman/csr_proc" at "../repo/csr_processor.xqm";
import module namespace csd_dm = "https://github.com/his-interop/openinfoman/csd_dm" at "../repo/csd_document_manager.xqm";
import module namespace csd_webconf =  "https://github.com/his-interop/openinfoman/csd_webconf" at "../repo/csd_webapp_config.xqm";


declare   namespace   csd = "urn:ihe:iti:csd:2013";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare   namespace   xforms = "http://www.w3.org/2002/xforms";
declare namespace xs = "http://www.w3.org/2001/XMLSchema";

declare variable $page:csd_docs := csd_dm:registered_documents($csd_webconf:db);

declare
  %rest:path("/CSD/csr/{$name}/careServicesRequest")
  %rest:consumes("application/xml", "text/xml", "multipart/form-data")  
  %rest:POST("{$careServicesRequest}")
  function page:csr($name,$careServicesRequest) 
{ 
if (csd_dm:document_source_exists($csd_webconf:db,$name)) then 
 csr_proc:process_CSR($careServicesRequest/careServicesRequest,csd_dm:open_document($csd_webconf:db,$name))   
else
  (:need appropriate error handling:)
  ()

};


declare updating
  %rest:path("/CSD/csr/{$name}/careServicesRequest/update")
  %rest:consumes("application/xml", "text/xml", "multipart/form-data")  
  %rest:POST("{$careServicesRequest}")
  function page:csr_updating($name,$careServicesRequest) 
{ 
if (csd_dm:document_source_exists($csd_webconf:db,$name)) then 
 csr_proc:process_updating_CSR($careServicesRequest/careServicesRequest,csd_dm:open_document($csd_webconf:db,$name))   
else
  (:need appropriate error handling:)
  ()

};


declare
  %rest:path("/CSD/csr/{$name}/adhoc")
  %rest:consumes("application/xml", "text/xml", "multipart/form-data")
  %rest:POST
  %rest:form-param("adhoc","{$adhoc}")
  %rest:form-param("content", "{$content}","application/xml")
function page:adhoc($name,$adhoc,$content) {    
if (csd_dm:document_source_exists($csd_webconf:db,$name)) then 
(:  csr_proc:process_CSR_adhoc(fn:parse-xml($adhoc),csd_dm:open_document($csd_webconf:db,$name)) :)
let  $adhoc_doc := csr_proc:create_adhoc_doc(string($adhoc),$content)
return  csr_proc:process_CSR($adhoc_doc,csd_dm:open_document($csd_webconf:db,$name))
(:  
  return  csr_proc:process_CSR($adhoc_doc,csd_dm:open_document($csd_webconf:db,$name))      :)
else
  (:need appropriate error handling:)
  ()

};


declare function page:function_list()  {
  <span>
    <h2>Care Services Request - Stored Queries</h2>
    <ul>
      { 
      for $function in ($csd_webconf:stored_functions,$csd_webconf:stored_updating_functions)
      let  $uuid := string($function/@uuid)
      order by $function/@uuid
      return  
      <li>
      UUID: {string($uuid)}  <br/>
      Method: <blockquote><pre>{string($function/definition)} </pre></blockquote>
      Content: {string(csd_webconf:lookup_stored_content_type($uuid)) }
      Description: <blockquote>{$function/description/*}</blockquote>
      Instance:   <blockquote><pre>{serialize($function/xforms:instance/careServicesRequest,map{'indent':='yes'})} </pre></blockquote>
      {if (exists($function/xs:schema)) then  ("Schema: ",string($function/xs:schema),<br/>) else () }
      {if (count( $function/xforms:bind) > 0) then
       ("Bindings: ",
       <blockquote>
	 <ul>
           {for $bind in $function/xforms:bind return <li><b>Node set</b>: {string($bind/@nodeset)} <br/><b>Type</b>: {string($bind/@type)}</li>}
	 </ul>
       </blockquote>
       ) else () 
       }
      </li>      
      }
    </ul>
  </span>
};


declare
  %rest:path("/CSD/csr")
  %rest:GET
  %output:method("xhtml")
  function page:csr_list() 
{ 
let $list := page:function_list()
let $response := page:endpoints()
return page:wrapper($list,$response)
};


declare function page:wrapper($list,$requests) {
 <html>
  <head>

    <link href="{$csd_webconf:baseurl}static/bootstrap/css/bootstrap.css" rel="stylesheet"/>
    <link href="{$csd_webconf:baseurl}static/bootstrap/css/bootstrap-theme.css" rel="stylesheet"/>
    

    <script src="https://code.jquery.com/jquery.js"/>
    <script src="{$csd_webconf:baseurl}static/bootstrap/js/bootstrap.min.js"/>

    <script src="https://code.jquery.com/jquery.js"/>
    <script src="{$csd_webconf:baseurl}static/bootstrap/js/bootstrap.min.js"/>
   <script type="text/javascript">
    $( document ).ready(function() {{
      $('#tab_list a').click(function (e) {{
	e.preventDefault()
	$(this).tab('show')
      }});
      $('#tab_requests a').click(function (e) {{
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
    <div class='container'>
      <ul class="nav nav-tabs">
	<li id='tab_list' class="active"><a  href="#list">Available Functions</a></li>
	<li id='tab_requests'><a  href="#requests">careServiceRequest Endpoints</a></li>
      </ul>
      <div class="tab-content panel">
	<div class="tab-pane active panel-body" id="list">{$list}</div>
	<div class="tab-pane active panel-body" id="requests">{$requests}</div>
      </div>
    </div>
  </body>
 </html>
};


declare function page:endpoints() {
<span>
    <h2>Care Services Request - Endpoints</h2>
    <ul>
      {
	for $name in $page:csd_docs
	return 
	<li>
	  Submit Care Services Request for {$name} at:
	  <pre>{$csd_webconf:baseurl}//CSD/csr/{$name}/careServicesRequest</pre> 
	  <br/>
	  Submit ad-hoc query:
	  <form method='post' action="/CSD/csr/{$name}/adhoc"  enctype="multipart/form-data">
	    <label for="adhoc">Ad-Hoc Query</label><textarea  rows="10" cols="80" name="adhoc" >{$page:sample}</textarea>
	    <br/>
	    <label for="content">Content Type</label><input    cols="80" name="content" value="text/html"/>
	    <br/>
	    <input type="submit" value="submit"/>
	  </form>
	</li>
      }
    </ul>
  </span>
};






declare variable $page:sample := 
"<html xmlns:csd='urn:ihe:iti:csd:2013'>
<body>
<ul>
  <li>You have {count(/csd:CSD/csd:providerDirectory/*)} providers.</li>
  <li>You have {count(/csd:CSD/csd:facilityDirectory/*)} facilities.</li>
<li>You have {count(/csd:CSD/csd:organizationDirectory/*)} organizations.</li>
<li>You have {count(/csd:CSD/csd:serviceDirectory/*)} services.</li>
</ul>
</body>
</html>";





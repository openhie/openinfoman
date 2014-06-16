module namespace page = 'http://basex.org/modules/web-page';

import module namespace csd_webconf =  "https://github.com/his-interop/openinfoman/csd_webconf" at "../repo/csd_webapp_config.xqm";
import module namespace csr_proc = "https://github.com/his-interop/openinfoman/csr_proc" at "../repo/csr_processor.xqm";
declare   namespace   xforms = "http://www.w3.org/2002/xforms";
declare namespace xs = "http://www.w3.org/2001/XMLSchema";
declare   namespace   csd = "urn:ihe:iti:csd:2013";
declare default element  namespace   "urn:ihe:iti:csd:2013";
import module namespace random = "http://basex.org/modules/random";
import module namespace bin = "http://expath.org/ns/binary";
declare variable $page:xsl := "../resources/doc_careServiceFunctions.xsl";

declare
  %rest:path("/CSD/storedFunctions")
  %rest:GET
  %output:method("xhtml")
  function page:csr_list() 
{ 
if (not (db:is-xml($csd_webconf:db,$csr_proc:stored_functions_doc))) then
  page:redirect(concat($csd_webconf:baseurl,"CSD/storedFunctions/init"))
else 
  let $new := page:new_stored_function()
  let $reload:= <span>
    <h2>Registered Stored Queries</h2>
    <ul>
      <li>{count(csr_proc:stored_functions($csd_webconf:db))} Stored Functions <br/></li>
      <li>{count(csr_proc:stored_updating_functions($csd_webconf:db))} Stored Updating Functions <br/></li>
      <li><a href="/CSD/storedFunctions/reload">Reload stored functions from disk</a> </li>

      <li>    <a href="{$csd_webconf:baseurl}CSD/storedFunctions/export_doc">Export Documentation</a></li>
      <li><a href="{$csd_webconf:baseurl}CSD/storedFunctions/export_funcs">Export Functions</a></li>
      <li><a href="{$csd_webconf:baseurl}CSD/storedFunctions/clear">Clear All Stored Functions</a></li>
    </ul>
  </span>
  let $list := page:function_list()
  return page:wrapper(($reload,$list),$new)
};

declare updating
  %rest:path("/CSD/storedFunctions/upload")
  %rest:consumes("application/xml", "text/xml", "multipart/form-data")
  %rest:form-param("upload","{$upload}")
  %rest:POST
  function page:upload($upload) 
{
 for $name    in map:keys($upload)
 let $content := $upload($name)
 let $func := parse-xml(bin:decode-string($content, 'UTF-8'))
 return
   (
     csr_proc:load_stored_function($csd_webconf:db,$func/careServicesFunction)
     ,
   db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/storedFunctions")))
  )


};

declare function page:new_stored_function() 
{
  <span>
   <h2>Upload careServicesFunction Document</h2>
   <form method='post' action="/CSD/storedFunctions/upload"  enctype="multipart/form-data">
   <label for="upload">Upload</label><input name='upload' type='file'/>
   <input type="submit" value="submit"/>
   </form>
   <h2>Create New Stored Function</h2>
   <form method='post' action="/CSD/storedFunctions/create"  enctype="multipart/form-data">
     <label for="uuid">UUID</label><input    size="42" name="uuid" value="{random:uuid()}"  readonly="readonly"/>
     <br/>
     <label for="content">Content Type</label><input    cols="80" name="content" value="text/html"/>
     <br/>
     <label for="description">Description</label><textarea  rows="20" cols="80" name="description" ></textarea>
     <br/>
     <label for="query">XQuery</label><textarea  rows="20" cols="80" name="query" ></textarea>
     <br/>
     <input type="submit" value="submit"/>
   </form>
 </span>
};


declare  updating 
  %rest:path("/CSD/storedFunctions/delete/{$uuid}")
  function page:delete($uuid) 
  {
    (
      csr_proc:delete_stored_function($csd_webconf:db,$uuid),
      db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/storedFunctions")))
    )

};

declare
  %rest:path("/CSD/storedFunctions/download/{$uuid}")
  function page:download($uuid) 
  {
    (
      csr_proc:get_function_definition($csd_webconf:db,$uuid),
      csr_proc:get_updating_function_definition($csd_webconf:db,$uuid)
    )[1]

};


declare  updating 
  %rest:path("/CSD/storedFunctions/clear")
  function page:clear() 
  {
    (
      csr_proc:clear_stored_functions($csd_webconf:db),
      db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/storedFunctions")))
    )

};

declare  updating 
  %rest:path("/CSD/storedFunctions/create")
  %rest:consumes("application/xml", "text/xml", "multipart/form-data")
  %rest:POST
  %rest:form-param("query","{$query}")
  %rest:form-param("description","{$description}")
  %rest:form-param("content", "{$content}","application/xml")
  %rest:form-param("uuid", "{$uuid}")
  function page:create($uuid,$query,$description,$content)
{ 
(  if ($uuid) then 
   let $func := 
   <careServicesFunction uuid="{$uuid}" content-type="{$content}">
     <description>{$description}</description>
     <definition>{$query}</definition>
   </careServicesFunction>
   return csr_proc:load_stored_function($csd_webconf:db,$func)
  else (),
    db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/storedFunctions")))
)
};


declare updating
  %rest:path("/CSD/storedFunctions/init")
  %rest:GET
  function page:init()
{ 
(csr_proc:init($csd_webconf:db),
db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/storedFunctions")))
)
};

declare updating
  %rest:path("/CSD/storedFunctions/reload")
  %rest:GET
  function page:reload()
{ 
(csr_proc:load_functions_from_files($csd_webconf:db),
db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/storedFunctions")))
)
};




declare function page:redirect($redirect as xs:string) as element(restxq:redirect)
{
  <restxq:redirect>{ $redirect }</restxq:redirect>
};


declare function page:display_function($function,$updating) {
  let  $uuid := string($function/@uuid)
  return  <span id="{$function/@uuid}">
    {if ($updating) then  "(Updating) " else ()}
    UUID: {string($uuid)}  <br/>
    Method: <blockquote><pre>{string($function/definition)} </pre></blockquote>
    Content: {string(csr_proc:lookup_stored_content_type($csd_webconf:db,$uuid)) } <br/>
    Description: <blockquote>{$function/description}</blockquote>
    Instance:   <blockquote><pre>{serialize($function/xforms:instance/careServicesRequest,map{'indent':='yes'})} </pre></blockquote>
    {if (exists($function/@method)) then  ("Method: ",string($function/@method),<br/>) else () }
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
  </span>
};

declare 
  %rest:path("/CSD/storedFunctions/export_funcs")
  %rest:GET
  function page:export_funcs() 
{
  <careServiceFunctions 
    xmlns:xforms="http://www.w3.org/2002/xforms" 
    xmlns:csd="urn:ihe:iti:csd:2013" 
    xmlns:xi="http://www.w3.org/2001/XInclude" 
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:hfp="http://www.w3.org/2001/XMLSchema-hasFacetAndProperty" 
     >
  {(
    csr_proc:stored_functions($csd_webconf:db)
    ,csr_proc:stored_updating_functions($csd_webconf:db)
   )}
 </careServiceFunctions>
};

declare 
  %rest:path("/CSD/storedFunctions/export_doc")
  %rest:GET
  %output:method("xhtml")
  function page:export_doc() 
{
  let $funcs := 
  <careServiceFunctions 
    xmlns:xforms="http://www.w3.org/2002/xforms" 
    xmlns:csd="urn:ihe:iti:csd:2013" 
    xmlns:xi="http://www.w3.org/2001/XInclude" 
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:hfp="http://www.w3.org/2001/XMLSchema-hasFacetAndProperty" 
     >
  {(
    csr_proc:stored_functions($csd_webconf:db)
    ,csr_proc:stored_updating_functions($csd_webconf:db)
   )}
 </careServiceFunctions>
(: return $funcs :)
 return xslt:transform($funcs,doc($page:xsl))   
};


declare function page:function_list()  {
  <span>
    <h2>Function List</h2>
    <ul>
    {
      for $function in (csr_proc:stored_functions($csd_webconf:db),csr_proc:stored_updating_functions($csd_webconf:db))
      return  
      <li>UUID: {string($function/@uuid)} {"  "}
      <i>
	{substring(string($function/description),1,100)}
	{if (string-length(string($function/description)) > 100) then "..." else ()}
      </i>
      <br/>
      <a href="#{$function/@uuid}">View</a>
      <a href="/CSD/storedFunctions/download/{$function/@uuid}">Download</a>
      <a href="/CSD/storedFunctions/delete/{$function/@uuid}" onClick="return confirm('This will remove the ability to execute this function. are you sure?');">Delete</a>
      </li>
    }
    </ul>

    <ul>
    {
      (
	for $function in csr_proc:stored_functions($csd_webconf:db)
	return   <li>{page:display_function($function,false())}</li>
       ,
        for $function in csr_proc:stored_updating_functions($csd_webconf:db)
        return  <li>{page:display_function($function,true())}</li>
      )
    }
    </ul>
  </span>
};


 
declare function page:wrapper($list,$new) {
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
      $('#tab_new a').click(function (e) {{
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
	<li id='tab_new'><a  href="#new">Upload Function</a></li>
      </ul>
      <div class="tab-content panel">
	<div class="tab-pane active panel-body" id="list">{$list}</div>
	<div class="tab-pane panel-body" id="new">{$new}</div>
      </div>
    </div>
  </body>
 </html>
};




 
declare function page:wrapper_simple($content) {
 <html>
  <head>

    <link href="{$csd_webconf:baseurl}static/bootstrap/css/bootstrap.css" rel="stylesheet"/>
    <link href="{$csd_webconf:baseurl}static/bootstrap/css/bootstrap-theme.css" rel="stylesheet"/>
    

    <script src="https://code.jquery.com/jquery.js"/>
    <script src="{$csd_webconf:baseurl}static/bootstrap/js/bootstrap.min.js"/>

    <script src="https://code.jquery.com/jquery.js"/>
    <script src="{$csd_webconf:baseurl}static/bootstrap/js/bootstrap.min.js"/>

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
    <div class='container'>{$content}</div>
  </body>
 </html>
};


module namespace page = 'http://basex.org/modules/web-page';

import module namespace csd_webconf =  "https://github.com/his-interop/openinfoman/csd_webconf" at "../repo/csd_webapp_config.xqm";
import module namespace csr_proc = "https://github.com/his-interop/openinfoman/csr_proc" at "../repo/csr_processor.xqm";
declare   namespace   xforms = "http://www.w3.org/2002/xforms";
declare namespace xs = "http://www.w3.org/2001/XMLSchema";
declare   namespace   csd = "urn:ihe:iti:csd:2013";
declare default element  namespace   "urn:ihe:iti:csd:2013";



declare
  %rest:path("/CSD/storedFunctions")
  %rest:GET
  %output:method("xhtml")
  function page:csr_list() 
{ 
if (not (db:is-xml($csd_webconf:db,$csr_proc:stored_functions_doc))) then
  let $content:= <span>
    <h2>No Registered Functions</h2>
    Please <a href="/CSD/storedFunctions/init">intialize the stored function  manager</a> in order to start using the stored functions
  </span>
  return page:wrapper_simple($content)
else 
  let $new := ()
  let $reload:= <span>
    <h2>Load Registered Functions</h2>
    <a href="/CSD/storedFunctions/reload">Reload stored functions from disk</a> 
  </span>  
  let $list := page:function_list()
  return page:wrapper(($reload,$list),$new)
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
  return  <span>
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



declare function page:function_list()  {
  <span>
    <h2>Registered Stored Queries</h2>
    {count(csr_proc:stored_functions($csd_webconf:db))}
    <ul>
    {(
      for $function in (csr_proc:stored_functions($csd_webconf:db))
      return  
      <li>{page:display_function($function,false())}</li>
      ,
      for $function in (csr_proc:stored_updating_functions($csd_webconf:db))
      return  
      <li>{page:display_function($function,true())}</li>

    )}
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


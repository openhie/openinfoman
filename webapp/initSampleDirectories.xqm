module namespace page = 'http://basex.org/modules/web-page';

import module namespace csd_lsd = "https://github.com/his-interop/openinfoman/csd_lsd";
import module namespace csd_dm = "https://github.com/his-interop/openinfoman/csd_dm";
import module namespace csd_webconf =  "https://github.com/his-interop/openinfoman/csd_webconf";



declare function page:redirect($redirect as xs:string) as element(restxq:redirect)
{
  <restxq:redirect>{ $redirect }</restxq:redirect>
};

declare function page:nocache($response) {
(<http:response status="200" message="OK">  

  <http:header name="Cache-Control" value="must-revalidate,no-cache,no-store"/>
</http:response>,
$response)
};



declare
  %rest:path("/CSD/initSampleDirectory/directory/{$name}")
  %rest:GET
  %output:method("xhtml")
  function page:get_service_menu($name)
{
  let $response := page:services_menu($name) 
  return page:nocache(page:wrapper($response))
};

declare
  %rest:path("/CSD/initSampleDirectory/directory/{$name}/get")
  %rest:GET
  function page:get_directory($name)
{
  csd_lsd:get($csd_webconf:db,$name) 
};





declare updating   
  %rest:path("/CSD/initSampleDirectory/directory/{$name}/load")
  %rest:GET
  function page:load($name)
{ 
(
  csd_lsd:load($csd_webconf:db,$name)   ,
  csd_dm:register_document($csd_webconf:db,$name,csd_lsd:get_document_name($name)),
  db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/initSampleDirectory")))
)
};

declare updating   
  %rest:path("/CSD/initSampleDirectory/directory/{$name}/register")
  %rest:GET
  function page:register($name)
{ 
(
  csd_dm:register_document($csd_webconf:db,$name,csd_lsd:get_document_name($name)),
  db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/initSampleDirectory")))
)
};

declare updating   
  %rest:path("/CSD/initSampleDirectory/directory/{$name}/deregister")
  %rest:GET
  function page:deregister($name)
{ 
(
  csd_dm:deregister_document($csd_webconf:db,$name),
  db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/initSampleDirectory")))
)
};


declare updating   
  %rest:path("/CSD/initSampleDirectory/directory/{$name}/reload")
  %rest:GET
  function page:reload($name)
{ 
(
  csd_lsd:delete($csd_webconf:db,$name)   ,
  db:output(page:redirect(concat($csd_webconf:baseurl,concat("CSD/initSampleDirectory/directory/",$name,"/load"))))
)


};


declare function page:wrapper($response) {
 <html>
  <head>

    <link href="{$csd_webconf:baseurl}static/bootstrap/css/bootstrap.css" rel="stylesheet"/>
    <link href="{$csd_webconf:baseurl}static/bootstrap/css/bootstrap-theme.css" rel="stylesheet"/>    
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
    {$response}
  </body>
 </html>
};

declare
  %rest:path("/CSD/initSampleDirectory")
  %rest:GET
  %output:method("xhtml")
  function page:poll_service_list()
{ 
let $response :=
    <div class='container'>
      <div class='row'>
 	<div class="col-md-8">
	  <h2>Sample Directories</h2>
	  <ul>
	    {for $name in csd_lsd:sample_directories()
	    order by $name
	    return 
	    <li>
	      <a href="/CSD/initSampleDirectory/directory/{$name}">{$name}</a>
	      <br/>
	      {page:services_menu($name)}
	    </li>
	    }
	  </ul>
	</div>
      </div>
    </div>
return page:nocache(  page:wrapper($response))


};



declare function page:services_menu($name) {
  <ul> 
    {if (not(csd_lsd:exists($csd_webconf:db,$name))) then
    <li><a href="/CSD/initSampleDirectory/directory/{$name}/load">Initialize </a> {$name} </li>
  else 
    (
    <li><a href="/CSD/initSampleDirectory/directory/{$name}/get">Get </a> {$name}</li>,
    <li><a href="/CSD/initSampleDirectory/directory/{$name}/reload">Reload </a>{$name}</li>,
    if (csd_dm:is_registered($csd_webconf:db,$name)) then
    <li><a href="/CSD/initSampleDirectory/directory/{$name}/deregister">De-Register </a>{$name} from Document Manager</li>
    else 
    <li><a href="/CSD/initSampleDirectory/directory/{$name}/register">Register </a>{$name} with Document Manager</li>
  )
    }
  </ul>
};




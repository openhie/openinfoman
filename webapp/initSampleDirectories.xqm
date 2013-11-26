module namespace page = 'http://basex.org/modules/web-page';

import module namespace csd_lsd = "https://github.com/his-interop/openinfoman/csd_lsd" at "../repo/csd_load_sample_directories.xqm";
import module namespace file = "http://expath.org/ns/file";
declare namespace soap = "http://www.w3.org/2003/05/soap-envelope";
import module namespace request = "http://exquery.org/ns/request";

declare variable $page:db := 'provider_directory';


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
  csd_lsd:get($page:db,$name) 
};





declare updating   
  %rest:path("/CSD/initSampleDirectory/directory/{$name}/load")
  %rest:GET
  function page:load($name)
{ 
(
  csd_lsd:load($page:db,$name)   ,
  db:output(page:redirect(concat(request:scheme() , "://",request:hostname(),":",request:port(),"/CSD/initSampleDirectory")))
)


};
declare updating   
  %rest:path("/CSD/initSampleDirectory/directory/{$name}/reload")
  %rest:GET
  function page:reload($name)
{ 
(
  csd_lsd:reload($page:db,$name)   ,
  db:output(page:redirect(concat(request:scheme() , "://",request:hostname(),":",request:port(),"/CSD/initSampleDirectory")))
)


};


declare function page:wrapper($response) {
 <html>
  <head>

    <link href="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap/css/bootstrap.css" rel="stylesheet"/>
    <link href="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap/css/bootstrap-theme.css" rel="stylesheet"/>    
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
    {if (not(csd_lsd:exists($page:db,$name))) then
    <li><a href="/CSD/initSampleDirectory/directory/{$name}/load">Initialize {$name}</a> </li>
  else 
    (
    <li><a href="/CSD/initSampleDirectory/directory/{$name}/get">Get  {$name}</a></li>,
    <li><a href="/CSD/initSampleDirectory/directory/{$name}/reload">Reload {$name}</a></li>
  )
    }
  </ul>
};




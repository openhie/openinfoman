module namespace page = 'http://basex.org/modules/web-page';


import module namespace csd_mcs = "https://github.com/his-interop/openinfoman/csd_mcs" at "../repo/csd_merge_cached_services.xqm";
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
    {$response}
  </body>
 </html>
};



declare
  %rest:path("/CSD/mergeServices")
  %rest:GET
  %output:method("xhtml")
  function page:merge_menu()
{ 
let $response:=
  <div>
    <div class='container'>
      <div class='row'>
 	<div class="col-md-8">
	  <h2>Merge Cached Service Directories</h2>
	  <ul>
	    {
	      if (not(csd_mcs:store_exists($page:db))) then
	      <li><a href="/CSD/mergeServices/init"> init merge services store</a></li>
	    else 
	      (
	      <li><a href="/CSD/mergeServices/merge">merge services</a></li>,
	      <li><a href="/CSD/mergeServices/get">get merged services</a></li>,
	      <li><a href="/CSD/mergeServices/empty">empty services</a></li>
	      )
	    }
	  </ul>
	</div>
      </div>
    </div>
  </div>
  
return page:wrapper($response)

};


declare updating 
  %rest:path("/CSD/mergeServices/init")
  %rest:GET
  function page:init()
{ 
  (
  csd_mcs:init_store($page:db)
  ,
  db:output(page:redirect(concat(request:scheme(),"://",request:hostname(),":",request:port(),"/CSD/mergeServices")))
  )

};

declare updating 
  %rest:path("/CSD/mergeServices/merge")
  %rest:GET
  function page:merge()
{ 
  (
  csd_mcs:merge($page:db)
  ,
  db:output(page:redirect(concat(request:scheme(),"://",request:hostname(),":",request:port(),"/CSD/mergeServices")))
  )

};

declare updating 
  %rest:path("/CSD/mergeServices/empty")
  %rest:GET
  function page:empty()
{ 
  (
  csd_mcs:merge($page:db)
  ,
  db:output(page:redirect(concat(request:scheme(),"://",request:hostname(),":",request:port(),"/CSD/mergeServices")))
  )

};

declare 
  %rest:path("/CSD/mergeServices/get")
  %rest:GET
  function page:get()
{ 
  csd_mcs:get($page:db)

};


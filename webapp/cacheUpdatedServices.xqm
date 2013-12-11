module namespace page = 'http://basex.org/modules/web-page';


import module namespace csd_psd = "https://github.com/his-interop/openinfoman/csd_psd" at "../repo/csd_poll_service_directories.xqm";
import module namespace csd_dm = "https://github.com/his-interop/openinfoman/csd_dm" at "../repo/csd_document_manager.xqm";
import module namespace csd_lsc = "https://github.com/his-interop/openinfoman/csd_lsc" at "../repo/csd_local_services_cache.xqm";
import module namespace csd_qus =  "https://github.com/his-interop/openinfoman/csd_qus" at "../repo/csd_query_updated_services.xqm";
import module namespace csd_webconf =  "https://github.com/his-interop/openinfoman/csd_webconf" at "../repo/csd_webapp_config.xqm";


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

declare updating
  %rest:path("/CSD/cacheService/init_cache_meta")
  %rest:GET
  function page:init_cache_meta()
{
  (csd_lsc:init_cache_meta($csd_webconf:db)
  ,
  db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/cacheService")))
  )
  
};

declare
  %rest:path("/CSD/cacheService/cache_meta")
  %rest:GET
  function page:get_cache_meta()
{
  csd_lsc:get_cache_data($csd_webconf:db,())
};


declare
  %rest:path("/CSD/cacheService/directory/{$name}")
  %rest:GET
  %output:method("xhtml")
  function page:get_service_menu($name)
{
  let $response := <span><h3>{$name}</h3>{page:services_menu($name) }</span>
  return page:nocache(page:wrapper($response))
};

declare
  %rest:path("/CSD/cacheService/directory/{$name}/cache_meta")
  %rest:GET
  function page:get_service_cache_meta($name)
{
  csd_lsc:get_cache_data($csd_webconf:db,$name) 
};


declare updating
  %rest:path("/CSD/cacheService/directory/{$name}/create_cache")
  %rest:GET
  function page:create_cache($name)
{
  (
  csd_lsc:create_cache($csd_webconf:db,$name)
  ,
  db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/cacheService")))
  )


};

declare updating
  %rest:path("/CSD/cacheService/directory/{$name}/drop_cache_meta")
  %rest:GET
  function page:drop_service_cache_meta($name)
{
  (
  csd_lsc:drop_cache_data($csd_webconf:db,$name)
  ,
  db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/cacheService")))
  )


};

declare
  %rest:path("/CSD/cacheService/directory/{$name}/get_cache")
  %rest:GET
  function page:get_cache($name)
{ 
 csd_lsc:get_cache($csd_webconf:db,$name) 
};

declare updating
  %rest:path("/CSD/cacheService/directory/{$name}/empty_cache")
  %rest:GET
  function page:empty_cache($name)
{ 
(
  csd_lsc:empty_cache($csd_webconf:db,$name) 
  ,
  db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/cacheService")))
  )

};



declare updating   
  %rest:path("/CSD/cacheService/directory/{$name}/update_cache")
  %rest:GET
  function page:update_cache($name)
{ 
(
  csd_lsc:update_cache($csd_webconf:db,$name)   ,
  db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/cacheService")))
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
    <div class='container'>    {$response}</div>
  </body>
 </html>
};

declare
  %rest:path("/CSD/cacheService")
  %rest:GET
  %output:method("xhtml")
  function page:poll_service_list()
{ 
let $services := csd_psd:registered_directories($csd_webconf:db)
let $response :=
    <div >
      <div class='row'>
 	<div class="col-md-8">
	  <h2>Global Operations</h2>
	  <ul>
	    {   if ( csd_lsc:cache_meta_exists($csd_webconf:db)) then
	       <li> <a href="{$csd_webconf:baseurl}CSD/cacheService/cache_meta">Get all cache Meta-Data</a></li>
	     else 
	       <li> <a href="{$csd_webconf:baseurl}CSD/cacheService/init_cache_meta">Init cache Meta-Data</a></li>

	    }
	  </ul>
	</div>
      </div>
      {   
      if ( csd_lsc:cache_meta_exists($csd_webconf:db)) then
      <div class='row'>
 	<div class="col-md-8">
	  <h2>Service Directory Operations</h2>
	  <ul>
	    {for $name in $services
	    let $mtime := csd_lsc:get_service_directory_mtime($csd_webconf:db,$name)
	    order by $name
	    return 
	    <li>
	      <b><a href="/CSD/cacheService/directory/{$name}">{$name}</a> last cached on {$mtime}</b>:
	      <br/>
	      {page:services_menu($name)}
	    </li>
	    }
	  </ul>
	</div>
      </div>
      else ()
      }
    </div>
return page:nocache(  page:wrapper($response))


};



declare updating   
  %rest:path("/CSD/cacheService/directory/{$name}/register")
  %rest:GET
  function page:register($name)
{ 
(
  csd_dm:register_document($csd_webconf:db,$name,csd_lsc:get_document_name($name)) ,
  db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/cacheService")))
)
};

declare updating   
  %rest:path("/CSD/cacheService/directory/{$name}/deregister")
  %rest:GET
  function page:deregister($name)
{ 
(
  csd_dm:deregister_document($csd_webconf:db,$name),
  db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/cacheService")))
)
};


declare function page:services_menu($name) {
  let $url := csd_psd:get_service_directory_url($csd_webconf:db,$name)
  let $mtime := csd_lsc:get_service_directory_mtime($csd_webconf:db,$name)
  return 
  <ul>
    {if (not(csd_lsc:directory_exists($csd_webconf:db,$name))) then
    <li><a href="/CSD/cacheService/directory/{$name}/create_cache">Create cache of {$name}</a> </li>
  else 
    (
    <li><a href="/CSD/cacheService/directory/{$name}/empty_cache">Empty local cache of {$name}</a> </li>,
    <li><a href="/CSD/cacheService/directory/{$name}/get_cache">Get local cache  of {$name}</a> </li>,
    <li>
      <a href="/CSD/cacheService/directory/{$name}/update_cache" >Update local cache  of {$name}</a> 
      <p>
	<b >WARNING:</b>An InfoMan trying to cache its own service directory will result in a deadlock.  see <a href="https://github.com/BaseXdb/basex/issues/173">this issue</a>
      </p>
      </li>,
      <li><a href="/CSD/cacheService/directory/{$name}/cache_meta">Get cache Meta Data  for {$name}</a></li>,
      <li><a href="/CSD/cacheService/directory/{$name}/drop_cache_meta">Drop cache Meta Data  of {$name}</a></li>,
      if (not(csd_dm:is_registered($csd_webconf:db,$name))) then 
        <li><a href="/CSD/cacheService/directory/{$name}/register">Register local cache of {$name} with document manager</a></li>
      else
        <li><a href="/CSD/cacheService/directory/{$name}/deregister">Deregister local cache  of {$name} with document manager</a></li>
  )
    }
  </ul>
};
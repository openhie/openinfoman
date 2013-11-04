module namespace page = 'http://basex.org/modules/web-page';


import module namespace csd_psd = "https://github.com/his-interop/openinfoman/csd_psd" at "../repo/csd_poll_service_directories.xqm";
import module namespace csd_lsc = "https://github.com/his-interop/openinfoman/csd_lsc" at "../repo/csd_local_services_cache.xqm";
import module namespace request = "http://exquery.org/ns/request";
import module namespace csd_qus =  "https://github.com/his-interop/openinfoman/csd_qus" at "../repo/csd_query_updated_services.xqm";
declare variable $page:db := 'provider_directory';


declare updating
  %rest:path("/CSD/cacheService/init_cache_meta")
  %rest:GET
  function page:init_cache_meta()
{
  csd_lsc:init_cache_meta($page:db)
};

declare
  %rest:path("/CSD/cacheService/cache_meta")
  %rest:GET
  function page:get_cache_meta()
{
  csd_lsc:get_cache_data($page:db,())
};
declare
  %rest:path("/CSD/cacheService/cache_meta/{$name}")
  %rest:GET
  function page:get_service_cache_meta($name)
{
  csd_lsc:get_cache_data($page:db,$name)
};
declare updating
  %rest:path("/CSD/cacheService/drop_cache_meta/{$name}")
  %rest:GET
  function page:drop_service_cache_meta($name)
{
  csd_lsc:drop_cache_data($page:db,$name)
};

declare
  %rest:path("/CSD/cacheService/get_cache/{$name}")
  %rest:GET
  function page:get_cache($name)
{ 
 csd_lsc:get_cache($page:db,$name) 
};

declare updating
  %rest:path("/CSD/cacheService/empty_cache/{$name}")
  %rest:GET
  function page:empty_cache($name)
{ 
 csd_lsc:empty_cache($page:db,$name) 
};



declare updating   
  %rest:path("/CSD/cacheService/update_cache/{$name}")
  %rest:GET
  function page:update_cache($name)
{ 
 csd_lsc:update_cache($page:db,$name) 
};



declare
  %rest:path("/CSD/cacheService")
  %rest:GET
  %output:method("xhtml")
  function page:poll_service_list()
{ 
let $services := csd_psd:get_services()
return
 <html>
  <head>

    <link href="http://{request:hostname()}:{request:port()}/static/bootstrap/css/bootstrap.css" rel="stylesheet"/>
    <link href="http://{request:hostname()}:{request:port()}/static/bootstrap/css/bootstrap-theme.css" rel="stylesheet"/>    
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
          <a class="navbar-brand" href="http://{request:hostname()}:{request:port()}/CSD">OpenInfoMan</a>
        </div>
      </div>
    </div>

    <div class='container'>
      <div class='row'>
 	<div class="col-md-8">
	  <h2>Global Operations</h2>
	  <ul>
	    <li> <a href="http://{request:hostname()}:{request:port()}/CSD/cacheService/cache_meta">Get all cache Meta-Data</a></li>
	  </ul>
	</div>
      </div>
      <div class='row'>
 	<div class="col-md-8">
	  <h2>Service Directory Operations</h2>
	  <ul>
	    {for $name in $services
	    let $url := csd_psd:get_service_directory_url($name)
	    let $mtime := csd_lsc:get_service_directory_mtime($page:db,$name)
	    order by $name
	    return 
	    <li>
	      <b>{$name} last cached on {$mtime}</b>:
	      <ul>
		<li><a href="/CSD/cacheService/empty_cache/{$name}">Empty local cache of {$name}</a> </li>
		<li><a href="/CSD/cacheService/get_cache/{$name}">Get local cache  of {$name}</a> </li>
		<li>
		  <a href="/CSD/cacheService/update_cache/{$name}" >Update local cache  of {$name}</a> 
		  <p><b >Note:</b> currently this funcionality has been disabled as there are  no live Services Directories (besides this one)  to query against.  Updating against yourself will cause a deadlock.
		  </p>
		</li>
		<li><a href="/CSD/cacheService/cache_meta/{$name}">Get cache Meta Data  for {$name}</a></li>
		<li><a href="/CSD/cacheService/drop_cache_meta/{$name}">Drop cache Meta Data  of {$name}</a></li>

	      </ul>
	    </li>
	    }
	  </ul>
	</div>
      </div>
    </div>
  </body>
</html>

};

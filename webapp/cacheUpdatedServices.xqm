module namespace page = 'http://basex.org/modules/web-page';


import module namespace csd_psd = "https://github.com/openhie/openinfoman/csd_psd";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace csd_lsc = "https://github.com/openhie/openinfoman/csd_lsc" ;
import module namespace csd_qus =  "https://github.com/openhie/openinfoman/csd_qus";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";


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
  %rest:path("/CSD/cacheService")
  %rest:GET
  %output:method("xhtml")
  function page:poll_service_list()
{ 
if ( not(csd_lsc:cache_meta_exists($csd_webconf:db))) then
  page:redirect(concat($csd_webconf:baseurl,"CSD/cacheService/init_cache_meta"))
else 
  let $services := csd_psd:registered_directories($csd_webconf:db)
  let $response :=
  <div >
    <div class='row'>
      <div class="col-md-8">
	<h2>Global Operations</h2>
	<ul>
	  <li> <a href="{$csd_webconf:baseurl}CSD/cacheService/cache_meta">Get all cache Meta-Data</a></li>
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
  return page:nocache(  csd_webconf:wrapper($response))


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
      <li><a href="/CSD/cacheService/directory/{$name}/drop_cache_meta">Drop cache Meta Data  of {$name}</a></li>
  )
    }
  </ul>
};
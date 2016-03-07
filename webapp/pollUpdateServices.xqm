module namespace page = 'http://basex.org/modules/web-page';


import module namespace csd_psd = "https://github.com/openhie/openinfoman/csd_psd";
import module namespace csd_lsc = "https://github.com/openhie/openinfoman/csd_lsc";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace csd_webui =  "https://github.com/openhie/openinfoman/csd_webui";
import module namespace csd_qus =  "https://github.com/openhie/openinfoman/csd_qus";







declare updating
  %rest:path("/CSD/registerService/named/{$name}")
  %output:method("xhtml")
  %rest:GET
  function page:register_named($name) 
{

  (
    let $sample := $csd_webconf:remote_services//serviceDirectory[@name=$name]
    return if (exists($sample)) then
      csd_psd:register_service($csd_webconf:db,$name,text{$sample/@url},$sample/credentials)
    else ()
  ,
  csd_webui:redirect_out("CSD/pollService")
  )
};

declare updating
  %rest:path("/CSD/registerService/basic_auth")
  %output:method("xhtml")
  %rest:query-param("name", "{$name}")
  %rest:query-param("url", "{$url}")
  %rest:query-param("password", "{$password}")
  %rest:query-param("username", "{$username}")
  %rest:GET
  function page:register_basic_auth($name,$url,$username,$password) 
{

  (
    let $credentials := <credentials type="basic_auth" username="{$username}" password="{$password}"/>
    return csd_psd:register_service($csd_webconf:db,$name,$url,$credentials)
      ,
  csd_webui:redirect_out("CSD/pollService")
  )

};


declare updating
  %rest:path("/CSD/registerService/basic_auth/{$name}")
  %output:method("xhtml")
  %rest:query-param("url", "{$url}")
  %rest:query-param("password", "{$password}")
  %rest:query-param("username", "{$username}")
  %rest:GET
  function page:update_basic_auth($name,$url,$username,$password) 
{

  (
    let $credentials := <credentials type="basic_auth" username="{$username}" password="{$password}"/>
    return csd_psd:register_service($csd_webconf:db,$name,$url,$credentials)
      ,
  csd_webui:redirect_out("CSD/pollService")
  )

};




declare
  %rest:path("/CSD/pollService/cache_meta")
  %rest:GET
  function page:get_cache_meta()
{
  csd_lsc:get_cache_data($csd_webconf:db,())
};


declare
  %rest:path("/CSD/pollService/directory/{$name}")
  %rest:GET
  %output:method("xhtml")
  function page:get_service_menu($name)
{
  let $response := <span><h3>{$name}</h3>{page:service_menu($name) }</span>
  return csd_webui:nocache(csd_webui:wrapper($response))
};

declare
  %rest:path("/CSD/pollService/directory/{$name}/cache_meta")
  %rest:GET
  function page:get_service_cache_meta($name)
{
  csd_lsc:get_cache_data($csd_webconf:db,$name) 
};


declare updating
  %rest:path("/CSD/pollService/directory/{$name}/create_cache")
  %rest:GET
  function page:create_cache($name)
{

  (
    if (csd_lsc:directory_exists($csd_webconf:db,$name)) 
    then csd_lsc:empty_cache($csd_webconf:db,$name)
    else csd_dm:empty($csd_webconf:db,$name)
  ,
  csd_webui:redirect_out("CSD/pollService")
  )


};

declare updating
  %rest:path("/CSD/pollService/directory/{$name}/drop_cache_meta")
  %rest:GET
  function page:drop_service_cache_meta($name)
{
  (
  csd_lsc:drop_cache_data($csd_webconf:db,$name)
  ,
  csd_webui:redirect_out("CSD/pollService")
  )


};

declare
  %rest:path("/CSD/pollService/directory/{$name}/get_cache")
  %rest:GET
  function page:get_cache($name)
{ 
 csd_lsc:get_cache($csd_webconf:db,$name) 
};

declare updating
  %rest:path("/CSD/pollService/directory/{$name}/empty_cache")
  %rest:GET
  function page:empty_cache($name)
{ 
  (
  csd_lsc:empty_cache($csd_webconf:db,$name) 
  ,
  csd_webui:redirect_out("CSD/pollService")
  )

};



declare updating   
  %rest:path("/CSD/pollService/directory/{$name}/update_cache")
  %rest:GET
  function page:update_cache($name)
{ 
(
  csd_lsc:update_cache($csd_webconf:db,$name)   ,
  csd_webui:redirect_out("CSD/pollService")
)

};

declare 
  %rest:path("/CSD/pollService/directory/{$name}/show_update_cache")
  %rest:GET
  function page:show_update_cache($name)
{ 

  let $db := $csd_webconf:db
  let $mtime :=  csd_lsc:get_service_directory_mtime($db,$name)
  let $soap := csd_psd:generate_soap_request($db,$name,$mtime)
  let $result := http:send-request($soap)
  return <a><r>{$result}</r><s>{$soap}</s></a>

};



declare
  %rest:path("/CSD/pollService/{$name}")
  %output:method("xhtml")
  %rest:GET
  function page:display_service_menu($name) 
{
  let $response :=     <div class='container'>
      <div class='row'>
 	<div class="col-md-8">
	{page:service_menu($name)}
	</div>
      </div>
    </div>
  return  csd_webui:nocache(page:wrapper($response))
};


declare
  %rest:path("/CSD/pollService/{$name}/get")
  %rest:query-param("mtime", "{$mtime}")
  %rest:GET
  function page:poll_service($name,$mtime)
{ 
if ($mtime) then
 csd_psd:poll_service_directory_soap_response($csd_webconf:db,$name,$mtime)
else
 csd_psd:poll_service_directory_soap_response($csd_webconf:db,$name,csd_lsc:get_service_directory_mtime($csd_webconf:db,$name))
};


declare
  %rest:path("/CSD/pollService/{$name}/get_csd")
  %rest:query-param("mtime", "{$mtime}")
  %rest:GET
  function page:poll_service_csd($name,$mtime)
{ 
if ($mtime) then
 csd_psd:poll_service_directory($csd_webconf:db,$name,$mtime)
else
 csd_psd:poll_service_directory($csd_webconf:db,$name,csd_lsc:get_service_directory_mtime($csd_webconf:db,$name))
};

declare
  %rest:path("/CSD/pollService/{$name}/get_soap")
  %rest:query-param("mtime", "{$mtime}")
  %rest:GET
  function page:poll_service_soap($name,$mtime)
{ 
 let $url := csd_psd:get_service_directory_url($csd_webconf:db,$name)    
 return (
 <rest:response>
   <http:response status="200" >
     <http:header name="Content-Type" value="application/soap+xml"/>
     <http:header name="Content-Disposition"  value="inline; filename=soap_query_updated_services_{$name}"/>
   </http:response>
   </rest:response>
   ,
   if ($mtime) then
     csd_qus:create_last_update_request($url,$mtime)
   else
     csd_qus:create_last_update_request($url,csd_lsc:get_service_directory_mtime($csd_webconf:db,$name))
 )

};

declare function page:wrapper($response) {
  let $headers :=   
  (<link rel="stylesheet" type="text/css" media="screen"   href="{csd_webui:generateURL('static/bootstrap-datetimepicker/css/bootstrap-datetimepicker.min.css')}"/>
  , <script src="{csd_webui:generateURL('static/bootstrap-datetimepicker/js/bootstrap-datetimepicker.js')}"/>
  , <script type="text/javascript">
    $( document ).ready(function() {{
      {
	for $name in csd_psd:registered_directories($csd_webconf:db)
	return (
	"$('#datetimepicker_",$name,"').datetimepicker({format: 'yyyy-mm-ddThh:ii:ss+00:00',startDate:'2013-10-01'});",
	"$('#soap_datetimepicker_",$name,"').datetimepicker({format: 'yyyy-mm-ddThh:ii:ss+00:00',startDate:'2013-10-01'}); ")
      }
    }});
    </script>
  )
  return csd_webui:wrapper($response,$headers)
};



declare
  %rest:path("/CSD/pollService")
  %rest:GET
  %output:method("xhtml")
  function page:poll_service_list()
{ 

   let $services := csd_psd:registered_directories($csd_webconf:db)
   let $unreg_services := 
     for $sample in  $csd_webconf:remote_services//serviceDirectory
     where not(csd_psd:is_registered($csd_webconf:db,$sample/text{@name}))
     return  $sample
    let $response :=
   <div>
     <div class='row'>
       <div class="col-md-4">
	 <h3>Add New Service (Basic Auth)</h3>
	 <form method='get' action="{csd_webui:generateURL('/CSD/registerService/basic_auth')}">
	   <ul>
	     <li><label for='name'> Name</label><input class='pull-right'  size="35"      name='name' type="text" value=""/>   </li>
	     <li><label for='url'>URL</label><input  class='pull-right' size="35"     name='url' type="text" value=""/>   </li>
	     <li><label for='username'>User Name</label><input  class='pull-right' size="35"     name='username' type="text" value=""/>   </li>
	     <li><label for='password'>Password</label><input  class='pull-right' size="35"     name='password' type="password" value=""/>   </li>
	   </ul>
	   <input type='submit' />
	 </form> 


       </div>
       <div class="col-md-4">
	 {
	   if (count($unreg_services) > 0) then
	   <span>
	     <h2>Add New Default Service</h2>
	     <ul>
	       {for $sample in $unreg_services
	       let $name := $sample/text{@name}
	       return 
	       <li>
		 <a href="{csd_webui:generateURL(('CSD/registerService/named',$name))}">Register {$name}</a>
	       </li>
	       }
	     </ul>
	   </span>
	   else ()
         }

	   <div >
	     <h2>Global Operations</h2>
	     <ul>
	       <li> <a href="{csd_webui:generateURL('CSD/pollService/cache_meta')}">Get all cache Meta-Data</a></li>
	     </ul>
	   </div>
       
       </div>


     </div>
     <div class='row'>
       <div class="col-md-4">
	 <h2>Registered Service Directories</h2>
	 {if (count($services) = 0) 
	 then <h4>No Services Registered</h4>
       else 
       <ul>
	 {for $name in $services
	 let $mtime := csd_lsc:get_service_directory_mtime($csd_webconf:db,$name)
	 order by $name
	 return 
	 <li>
	   <b><a href="{csd_webui:generateURL(('CSD/pollService',$name))}">{$name}</a></b> last <a href="{csd_webui:generateURL(('CSD/pollService/directory',$name))}">cached</a> on {$mtime}
	 </li>
	 }
       </ul>
	 }
       </div>
       <div class="col-md-4">
	 <h3>Update Service (Basic Auth)</h3>
	 {
	   for $name in $services
	   let $url := csd_psd:get_service_directory_url($csd_webconf:db,$name) 
	   return
	     <div id='svc-{$name}'>
	       <h2>{$name}</h2>
	       <form method='get' action="{csd_webui:generateURL(('/CSD/registerService/basic_auth',$name))}">
		 <ul>
		   <li><label for='url'>URL</label><input  class='pull-right' size="35"     name='url' type="text" value="{$url}"/></li>
		   <li><label for='username'>User Name</label><input  class='pull-right' size="35"     name='username' type="text" value=""/>   </li>
		   <li><label for='password'>Password</label><input  class='pull-right' size="35"     name='password' type="password" value=""/>   </li>
		 </ul>
		 <input type='submit' />
	       </form> 
	     </div>
	 }

       </div>

     </div>
   </div>
  
  return csd_webui:nocache(page:wrapper($response))
 
};

declare function page:service_menu($name) {
  let $url := csd_psd:get_service_directory_url($csd_webconf:db,$name)
  let $mtime := csd_lsc:get_service_directory_mtime($csd_webconf:db,$name)
  return 
<span>
  <pre>{$url}</pre>
  <p>
    modified: {$mtime}
  </p>
  <ul>
  <li>Caching
{csd_lsc:get_document_name($name)}
  <ul>
    {if (not(csd_lsc:directory_exists($csd_webconf:db,$name))) then
      (
      <li><a href="{csd_webui:generateURL(('CSD/pollService/directory',$name,'create_cache'))}">Create cache of {$name}</a> </li>
      )
  else 
    (
    <li><a href="{csd_webui:generateURL(('CSD/pollService/directory',$name, 'empty_cache'))}">Empty local cache of {$name}</a> </li>,
    <li><a href="{csd_webui:generateURL(('CSD/pollService/directory',$name,'get_cache'))}">Get local cache  of {$name}</a> </li>,
    <li>
      <a href="{csd_webui:generateURL(('CSD/pollService/directory',$name,'update_cache'))}" >Update local cache  of {$name}</a> 
      <p>
	<b >WARNING:</b>An InfoMan trying to cache its own service directory will result in a deadlock.  see <a href="https://github.com/BaseXdb/basex/issues/173">this issue</a>
      </p>
      </li>,
      <li><a href="{csd_webui:generateURL(('CSD/pollService/directory',$name,'cache_meta'))}">Get cache Meta Data  for {$name}</a></li>,
      <li><a href="{csd_webui:generateURL(('CSD/pollService/directory',$name,'drop_cache_meta'))}">Drop cache Meta Data  of {$name}</a></li>
  )
    }
  </ul>
  </li>
  <li>Testing
  <ul>
    <li><a href="{csd_webui:generateURL(('CSD/pollService',$name,'get'))}"> Query  {$name} for Updated Services using stored last modified time (SOAP result)</a> </li>
    <li><a href="{csd_webui:generateURL(('CSD/pollService',$name,'get_csd'))}"> Query  {$name} for Updated Services using stored last modified time (CSD result)</a> </li>
    <li><a href="{csd_webui:generateURL(('CSD/pollService',$name,'get_soap'))}"> Get {$name}'s Soap Query for Updated Services Request using stored last modified time</a>    </li>
    <li>
    Query {$name} for Updated Services by time
    <form method='get' action="{csd_webui:generateURL(('/CSD/pollService',$name,'get'))}">
      <input  size="35" id="datetimepicker_{$name}"    name='mtime' type="text" value="{$mtime}"/>   
      <input type='submit' />
    </form> 
    </li>
    <li>
    Get {$name}'s SOAP reuest for Query for Updated Services by time
    <form method='get' action="{csd_webui:generateURL(('/CSD/pollService',concat('soap_query_updated_services_',$name)))}">
      <input  size="35" id="soap_datetimepicker_{$name}"  name='mtime' type="text" value="{$mtime}"/>   
      <input type='submit' />
    </form> 
    </li>
  </ul>
  </li>
  </ul>
  To test submission on your machine you can do:
  <pre>curl --header "content-type: application/soap+xml" --data "@soap_query_updated_services_{$name}.xml" {$url}</pre>
  where soap_updated_services_{$name}.xml is  the downloaded soap request document.  Add authorization parameters as neccesary.
</span>
};  



module namespace page = 'http://basex.org/modules/web-page';


import module namespace csd_psd = "https://github.com/his-interop/openinfoman/csd_psd" at "../repo/csd_poll_service_directories.xqm";
import module namespace csd_lsc = "https://github.com/his-interop/openinfoman/csd_lsc" at "../repo/csd_local_services_cache.xqm";
import module namespace request = "http://exquery.org/ns/request";
import module namespace csd_qus =  "https://github.com/his-interop/openinfoman/csd_qus" at "../repo/csd_query_updated_services.xqm";

declare variable $page:db := 'provider_directory';


declare variable $page:samples :=
<serviceDirectoryLibrary>
  <serviceDirectory  name='rhea_simple_provider' url='http://rhea-pr.ihris.org/providerregistry/getUpdatedServices'/>
  <serviceDirectory   name='openinfoman_providers'  url='http://csd.ihris.org:8984/CSD/getUpdatedServices/providers/get'/>
  <serviceDirectory   name='openhim_providers'  url='https://openhim.jembi.org:5000/CSD/getUpdatedServices/providers/get'>
    <credentials type='basic_auth' username='test'  password='test'  />
  </serviceDirectory>
</serviceDirectoryLibrary>;


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
  %rest:path("/CSD/registerService/init")
  function page:init() 
{
  (
    csd_psd:init($page:db)
  ,
  db:output(page:redirect(concat(request:scheme(),"://",request:hostname(),":",request:port(),"/CSD/pollService")))
  )
};

declare updating
  %rest:path("/CSD/registerService/deregister/{$name}")
  %output:method("xhtml")
  %rest:GET
  function page:deregister_named($name) 
{

  (
    csd_psd:deregister_service($page:db,$name)
  ,
  db:output(page:redirect(concat(request:scheme(),"://",request:hostname(),":",request:port(),"/CSD/pollService")))
  )
};



declare updating
  %rest:path("/CSD/registerService/named/{$name}")
  %output:method("xhtml")
  %rest:GET
  function page:register_named($name) 
{

  (
    let $sample := $page:samples//serviceDirectory[@name=$name]
    return if (exists($sample)) then
      csd_psd:register_service($page:db,$name,text{$sample/@url},$sample/credentials)
    else ()
  ,
  db:output(page:redirect(concat(request:scheme(),"://",request:hostname(),":",request:port(),"/CSD/pollService")))
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
    return csd_psd:register_service($page:db,$name,$url,$credentials)
      ,
  db:output(page:redirect(concat(request:scheme(),"://",request:hostname(),":",request:port(),"/CSD/pollService")))
  )

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
  return page:nocache(page:wrapper($response))
};


declare
  %rest:path("/CSD/pollService/{$name}/get")
  %rest:query-param("mtime", "{$mtime}")
  %rest:GET
  function page:poll_service($name,$mtime)
{ 
if ($mtime) then
 csd_psd:poll_service_directory_soap_response($page:db,$name,$mtime)
else
 csd_psd:poll_service_directory_soap_response($page:db,$name,csd_lsc:get_service_directory_mtime($page:db,$name))
};


declare
  %rest:path("/CSD/pollService/{$name}/get_csd")
  %rest:query-param("mtime", "{$mtime}")
  %rest:GET
  function page:poll_service_csd($name,$mtime)
{ 
if ($mtime) then
 csd_psd:poll_service_directory($page:db,$name,$mtime)
else
 csd_psd:poll_service_directory($page:db,$name,csd_lsc:get_service_directory_mtime($page:db,$name))
};

declare
  %rest:path("/CSD/pollService/{$name}/get_soap")
  %rest:query-param("mtime", "{$mtime}")
  %rest:GET
  function page:poll_service_soap($name,$mtime)
{ 
 let $url := csd_psd:get_service_directory_url($page:db,$name)    
 return (
 <rest:response>
   <http:response status="200" >
     <http:header name="Content-Type" value="text/xml; charset=utf-8"/>
     <http:header name="Content-Disposition"  value="inline; filename=soap_query_updated_services_{$name}"/>
   </http:response>
   </rest:response>
   ,
   if ($mtime) then
     csd_qus:create_last_update_request($url,$mtime)
   else
     csd_qus:create_last_update_request($url,csd_lsc:get_service_directory_mtime($page:db,$name))
 )

};

declare function page:wrapper($response) {
 <html>
  <head>

    <link href="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap/css/bootstrap.css" rel="stylesheet"/>
    <link href="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap/css/bootstrap-theme.css" rel="stylesheet"/>
    

    <link rel="stylesheet" type="text/css" media="screen"   href="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap-datetimepicker/css/bootstrap-datetimepicker.min.css"/>

    <script src="https://code.jquery.com/jquery.js"/>
    <script src="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap/js/bootstrap.min.js"/>
    <script src="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap-datetimepicker/js/bootstrap-datetimepicker.js"/>
    <script type="text/javascript">
    $( document ).ready(function() {{
      {
	for $name in csd_psd:registered_directories($page:db)
	return (
	"$('#datetimepicker_",$name,"').datetimepicker({format: 'yyyy-mm-ddThh:ii:ss+00:00',startDate:'2013-10-01'});",
	"$('#soap_datetimepicker_",$name,"').datetimepicker({format: 'yyyy-mm-ddThh:ii:ss+00:00',startDate:'2013-10-01'}); ")
      }
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
          <a class="navbar-brand" href="{request:scheme()}://{request:hostname()}:{request:port()}/CSD">OpenInfoMan</a>
        </div>
      </div>
    </div>
    <div class='container'> {$response}</div>
  </body>
 </html>
};



declare
  %rest:path("/CSD/pollService")
  %rest:GET
  %output:method("xhtml")
  function page:poll_service_list()
{ 

let $response :=
  if (not(csd_psd:dm_exists($page:db))) then
  <span>
    <h2>No Service Directory Manager </h2>
    Please <a href="/CSD/registerService/init">intialize the services directory manager</a> in order to start polling remote service directories.
  </span>
  else 
    let $services := csd_psd:registered_directories($page:db)
    let $unreg_services := 
    for $sample in $page:samples//serviceDirectory
    where not(csd_psd:is_registered($page:db,$sample/text{@name}))
      return  $sample
   return
   <div>
     <div class='row'>
       <div class="col-md-4">
	 <h3>Add New Service (Basic Auth)</h3>
	 <form method='get' action="/CSD/registerService/basic_auth">
	   <ul>
	     <li><label for='name'> Name</label><input class='pull-right'  size="35"      name='name' type="text" value=""/>   </li>
	     <li><label for='url'>URL</label><input  class='pull-right' size="35"     name='url' type="text" value=""/>   </li>
	     <li><label for='username'>User Name</label><input  class='pull-right' size="35"     name='username' type="text" value=""/>   </li>
	     <li><label for='password'>Password</label><input  class='pull-right' size="35"     name='password' type="text" value=""/>   </li>
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
		 <a href="/CSD/registerService/named/{$name}">Register {$name}</a>
	       </li>
	       }
	     </ul>
	   </span>
	 else ()
}
       </div>
     </div>
     <div class='row'>
       <div class="col-md-8">
	 <h2>Registered Service Directories</h2>
	 {if (count($services) = 0) 
	 then <h4>No Services Registered</h4>
       else 
       <ul>
	 {for $name in $services
	 let $mtime := csd_lsc:get_service_directory_mtime($page:db,$name)
	 order by $name
	 return 
	 <li>
	   <b><a href="/CSD/pollService/{$name}">{$name}</a></b> last <a href="/CSD/cacheService/directory/{$name}">cached</a> on {$mtime}
	   <br/>
	   <b>Services:</b>  {page:service_menu($name)}
	 </li>
	 }
       </ul>
	 }
       </div>
     </div>
   </div>
  
return page:nocache(page:wrapper($response))

};

declare function page:service_menu($name) {
  let $url := csd_psd:get_service_directory_url($page:db,$name)
  let $mtime := csd_lsc:get_service_directory_mtime($page:db,$name)
  return 
<span>
  <ul>
    <li><a href="/CSD/pollService/{$name}/get"> Query  {$name} for Updated Services using stored last modified time (SOAP result)</a> </li>
    <li><a href="/CSD/pollService/{$name}/get_csd"> Query  {$name} for Updated Services using stored last modified time (CSD result)</a> </li>
    <li><a href="/CSD/pollService/{$name}/get_soap"> Get {$name}'s Soap Query for Updated Services Request using stored last modified time</a>    </li>
    <li><a href="/CSD/registerService/deregister/{$name}"> Deregister This Service</a>    </li>
    <li>
    Query {$name} for Updated Services by time
    <form method='get' action="/CSD/pollService/{$name}/get">
      <input  size="35" id="datetimepicker_{$name}"    name='mtime' type="text" value="{$mtime}"/>   
      <input type='submit' />
    </form> 
    </li>
    <li>
    Get {$name}'s SOAP reuest for Query for Updated Services by time
    <form method='get' action="/CSD/pollService/soap_query_updated_services_{$name}">
      <input  size="35" id="soap_datetimepicker_{$name}"  name='mtime' type="text" value="{$mtime}"/>   
      <input type='submit' />
    </form> 
    </li>

  </ul>
  To test submission on your machine you can do:
  <pre>curl --form "fileupload=@soap_query_updated_services_{$name}.xml" {$url}</pre>
  where soap_updated_services_{$name}.xml is  the downloaded soap request document
</span>
};  



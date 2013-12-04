module namespace page = 'http://basex.org/modules/web-page';

import module namespace svs_lsvs = "https://github.com/his-interop/openinfoman/svs_lsvs" at "../repo/svs_load_shared_value_sets.xqm";
declare namespace svs = "urn:ihe:iti:svs:2008";
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





declare updating   
  %rest:path("/CSD/SVS/initSampleSharedValueSet/init")
  %rest:GET
  function page:init()
{ 
(
  svs_lsvs:init_store($page:db),
  db:output(page:redirect(concat(request:scheme() , "://",request:hostname(),":",request:port(),"/CSD/SVS/initSampleSharedValueSet")))
)
};




declare
  %rest:path("/CSD/SVS/initSampleSharedValueSet/svs/{$id}")
  %rest:GET
  %output:method("xhtml")
  function page:get_svs_menu($id)
{
  let $response := page:svs_menu($id) 
  return page:nocache(page:wrapper($response))
};

declare
  %rest:path("/CSD/SVS/initSampleSharedValueSet/svs/{$id}/get")
  %rest:GET
  function page:get_shared_value_set($id)
{
  svs_lsvs:get($page:db,$id) 
};





declare updating   
  %rest:path("/CSD/SVS/initSampleSharedValueSet/svs/{$id}/load")
  %rest:GET
  function page:load($id)
{ 
(
  svs_lsvs:load($page:db,$id)   ,
  db:output(page:redirect(concat(request:scheme() , "://",request:hostname(),":",request:port(),"/CSD/SVS/initSampleSharedValueSet")))
)
};


declare updating   
  %rest:path("/CSD/SVS/initSampleSharedValueSet/svs/{$id}/reload")
  %rest:GET
  function page:reload($id)
{ 
(
  svs_lsvs:reload($page:db,$id)   ,
  db:output(page:redirect(concat(request:scheme() , "://",request:hostname(),":",request:port(),"/CSD/SVS/initSampleSharedValueSet")))
)
};

declare
  %rest:path("/CSD/SVS/initSampleSharedValueSet/svs/{$id}/lookup")
  %rest:GET
  %rest:query-param("code","{$code}")
  %output:method("xhtml")
  function page:lookup_code($id,$code) 
{
  let $set := svs_lsvs:get_value_set($page:db,$id)
  let $concept := svs_lsvs:get_code($page:db,$id,$code,())
  let $response := 
  <span>
    <h2>Code: {$code}</h2>
    <h3>Value Set: {text{$id}} ({text{$set/@displayName}})</h3>
    <ul>
      <li>displayName: {text{$concept/@displayName}}</li>
      <li>codeSystem: {text{$concept/@codeSystem}}</li>
    </ul>
    <a href="{request:scheme()}://{request:hostname()}:{request:port()}/CSD/SVS/initSampleSharedValueSet/">Return</a>
  </span>
  return page:wrapper($response)
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
    <div class='container'>
      <div class='row'>
 	<div class="col-md-8">
	  {$response}
	</div>
      </div>
    </div>
  </body>
 </html>
};

declare
  %rest:path("/CSD/SVS/initSampleSharedValueSet")
  %rest:GET
  %output:method("xhtml")
  function page:svs_list()
{ 
let $response :=
  if (not(svs_lsvs:store_exists($page:db))) then
    <span>
      <a href="/CSD/SVS/initSampleSharedValueSet/init">Initialize</a> Shared Value Sets Store
    </span>
    
  else 
    <span>
      <h2>Sample Shared Value Sets</h2>
      <p>
      {svs_lsvs:get_all_sets($page:db)}
      </p>
      <ul>
	{for $set in svs_lsvs:get_all_sets($page:db)/svs:ValueSet
	let $id := text{$set/@id}
	let $displayName := text{$set/@displayName}
	order by $set/@id
	return 
	<li>
	  <a href="/CSD/SVS/initSampleSharedValueSet/svs/{$id}">{$displayName} ({$id})</a>
	  <br/>
	  {page:svs_menu($id)}
	</li>
	}
      </ul>
    </span>
return page:nocache(  page:wrapper($response))


};



declare function page:svs_menu($id) {
  let $set := svs_lsvs:get_value_set($page:db,$id) 
  return 
    if (not($set)) then (<b>{$set}</b>) else 
      let $disp := text{$set/@displayName}
      return <ul>
	{if ($set/@file) then
	  if (not(svs_lsvs:exists($page:db,$id))) then
          <li><a href="/CSD/SVS/initSampleSharedValueSet/svs/{$id}/load">Initialize {$id} ({$disp})</a> </li>
          else 
	  (
	  <li><a href="/CSD/SVS/initSampleSharedValueSet/svs/{$id}/get">Get  {$id}</a></li>,
	  <li><a href="/CSD/SVS/initSampleSharedValueSet/svs/{$id}/reload">Reload {$id}</a></li>,
	  <li><form action="/CSD/SVS/initSampleSharedValueSet/svs/{$id}/lookup"><label for="code">Lookup Code</label><input name="code" type="text"/><input type="submit"/></form></li>
	  )
        else
	  (:not @file so its not something we can load/reload :)
	  (
	  <li><a href="/CSD/SVS/initSampleSharedValueSet/svs/{$id}/get">Get {$id}</a></li>,
	  <li><form action="/CSD/SVS/initSampleSharedValueSet/svs/{$id}/lookup"><label for="code">Lookup Code</label><input name="code" type="text"/><input type="submit"/></form></li>
	  )
	  }
       </ul>

};




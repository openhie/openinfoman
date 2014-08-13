module namespace page = 'http://basex.org/modules/web-page';

import module namespace csd_lsd = "https://github.com/openhie/openinfoman/csd_lsd";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
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



declare
  %rest:path("/CSD/initSampleDirectory/directory/{$name}")
  %rest:GET
  %output:method("xhtml")
  function page:get_service_menu($name)
{
  let $response := page:services_menu($name) 
  return page:nocache(csd_webconf:wrapper($response))
};

declare
  %rest:path("/CSD/initSampleDirectory/directory/{$name}/get")
  %rest:GET
  function page:get_directory($name)
{
  csd_dm:open_document($csd_webconf:db,$name) 
};





declare updating   
  %rest:path("/CSD/initSampleDirectory/directory/{$name}/load")
  %rest:GET
  function page:load($name)
{ 
(
  csd_lsd:load($csd_webconf:db,$name)   ,
  db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/initSampleDirectory")))
)
};



declare updating   
  %rest:path("/CSD/initSampleDirectory/directory/{$name}/reload")
  %rest:GET
  function page:reload($name)
{ 
(
  csd_dm:empty($csd_webconf:db,$name)   ,
  db:output(page:redirect(concat($csd_webconf:baseurl,concat("CSD/initSampleDirectory/directory/",$name,"/load"))))
)


};




declare
  %rest:path("/CSD/initSampleDirectory")
  %rest:GET
  %output:method("xhtml")
  function page:directory_list()
{ 
let $response :=
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

return page:nocache(  csd_webconf:wrapper($response))


};



declare function page:services_menu($name) {
  <ul> 
    {if (not(csd_dm:document_source_exists($csd_webconf:db,$name))) then
    <li><a href="/CSD/initSampleDirectory/directory/{$name}/load">Initialize </a> {$name} </li>
  else 
    (
    <li><a href="/CSD/initSampleDirectory/directory/{$name}/get">Get </a> {$name}</li>,
    <li><a href="/CSD/initSampleDirectory/directory/{$name}/reload">Reload </a>{$name}</li>
  )
    }
  </ul>
};




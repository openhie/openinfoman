module namespace page = 'http://basex.org/modules/web-page';


import module namespace csd_mcs = "https://github.com/openhie/openinfoman/csd_mcs";
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


declare updating   
  %rest:path("/CSD/mergeServices/register")
  %rest:GET
  function page:register() { 
(
  csd_dm:register_document($csd_webconf:db,csd_mcs:get_merge_doc_name(),$csd_mcs:merged_services_doc),
  db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/mergeServices")))
)
};

declare updating   
  %rest:path("/CSD/mergeServices/deregister")
  %rest:GET
  function page:deregister() 
{ 
(
  csd_dm:deregister_document($csd_webconf:db,csd_mcs:get_merge_doc_name()),
  db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/mergeServices")))
)
};




declare
  %rest:path("/CSD/mergeServices")
  %rest:GET
  %output:method("xhtml")
  function page:merge_menu()
{ 
if (not(csd_mcs:store_exists($csd_webconf:db))) then
  page:redirect(concat($csd_webconf:baseurl,"CSD/mergeServices/init"))
else 
  let $response:=
  <div>
    <div class='container'>
      <div class='row'>
 	<div class="col-md-8">
	  <h2>Merge Cached Service Directories</h2>
	  <ul>
	    <li><a href="/CSD/mergeServices/merge">merge services</a></li>
	    <li><a href="/CSD/mergeServices/get">get merged services</a></li>
	    <li><a href="/CSD/mergeServices/empty">empty services</a></li>
	    {
	      if (csd_dm:is_registered($csd_webconf:db,csd_mcs:get_merge_doc_name())) then
	      <li><a href="/CSD/mergeServices/deregister">deregister merge of remote from document store </a></li>
            else
	    <li><a href="/CSD/mergeServices/register">register merge of remote services from document manager</a></li>
	    }
	  </ul>
	</div>
      </div>
    </div>
  </div>
  
return csd_webconf:wrapper($response)

};


declare updating 
  %rest:path("/CSD/mergeServices/init")
  %rest:GET
  function page:init()
{ 
  (
  csd_mcs:init_store($csd_webconf:db)
  ,
  db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/mergeServices")))
  )

};

declare updating 
  %rest:path("/CSD/mergeServices/merge")
  %rest:GET
  function page:merge()
{ 
  (
  csd_mcs:merge($csd_webconf:db)
  ,
  db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/mergeServices")))
  )

};

declare updating 
  %rest:path("/CSD/mergeServices/empty")
  %rest:GET
  function page:empty()
{ 
  (
  csd_mcs:empty($csd_webconf:db)
  ,
  db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/mergeServices")))
  )

};

declare 
  %rest:path("/CSD/mergeServices/get")
  %rest:GET
  function page:get()
{ 
  csd_mcs:get($csd_webconf:db)

};


module namespace page = 'http://basex.org/modules/web-page';
import module namespace csd = "urn:ihe:iti:csd:2013" at "../repo/csd_base_library.xqm";
import module namespace csr_proc = "https://github.com/his-interop/openinfoman/csr_proc" at "../repo/csr_processor.xqm";
import module namespace request = "http://exquery.org/ns/request";


import module namespace csd_dm = "https://github.com/his-interop/openinfoman/csd_dm" at "../repo/csd_document_manager.xqm";
declare variable $page:db := 'provider_directory';
declare variable $page:test_doc_dir := "../resources/test_docs/";
declare variable $page:test_docs :=  file:list($page:test_doc_dir,boolean('false'),"*.xml");



declare 
  %output:method("xhtml")
  %rest:path("/CSD/test/{$name}")
  %rest:GET
function page:show_test_menu($name) {
  page:wrapper(page:test_menu($name))
};

declare
  %rest:path("/CSD/test/{$name}/{$test}")
  %rest:GET
  function page:test($name, $test as xs:string)
{
let $test_doc := page:get_test_doc($test)
return if ($test_doc) then
  csr_proc:process_CSR($test_doc/csd:careServicesRequest,csd_dm:open_document($page:db,$name))
else
   (:need better error handling:)
  <h2>Shame on you</h2>

};


declare
  %rest:path("/CSD/test_source/{$test}")
  %rest:GET
  %output:method("xml")
  function page:test_source(
    $test as xs:string)
{
let $test_doc := page:get_test_doc($test)
return if ($test_doc) then
 $test_doc
else
  <h2>Shame on you</h2>
};

declare function page:get_test_doc($test) {
let $dir_base := file:resolve-path($page:test_doc_dir)
let $file := file:resolve-path(concat($dir_base , "/" ,$test,".xml"))
return if ( file:exists($file)) 
then
  doc($file)
else
  ()
};

declare 
  %rest:path("/CSD/test")
  %rest:GET
  %output:method("xhtml")
  function page:list_tests() 
{
let $response:=    
<span>
  <h2>Registered Documents</h2>
  {
    for $name in csd_dm:registered_documents($page:db) 
    return <div class='row'><h4>Tests for <a href="/CSD/test/{$name}">{$name}</a></h4>{page:test_menu($name)}</div>
  }
</span>
return page:wrapper($response)
};



declare function page:test_menu($name) 
{
<span>
  <p>
  To test submission on your machine you can do:
  <pre>
  curl --form "fileupload=@test.xml" {request:scheme()}://{request:hostname()}:{request:port()}/CSD/csr/{$name}/careServicesRequest
  </pre>
  where test.xml is one of the downloaded source documents below
  </p>
  <ul>
    {for $test_doc in $page:test_docs
    order by $test_doc
    let $test := file:base-name($test_doc,".xml")
    return  <li>
    {$test}:<a href="/CSD/test/{$name}/{$test}"> process on server</a>  /
    <a href="/CSD/test_source/{$test}"> download source</a> 
  </li>
    }
  </ul>
</span>
};    


declare function page:wrapper($response) {
 <html>
  <head>

    <link href="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap/css/bootstrap.css" rel="stylesheet"/>
    <link href="{request:scheme()}://{request:hostname()}:{request:port()}/static/bootstrap/css/bootstrap-theme.css" rel="stylesheet"/>
    

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
    <div class='container'>{$response}</div>
  </body>
 </html>
};

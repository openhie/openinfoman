module namespace page = 'http://basex.org/modules/web-page';

import module namespace csr_proc = "https://github.com/openhie/openinfoman/csr_proc";
(:import module namespace csr_adpt = "https://github.com/openhie/openinfoman/csr_adpt"; :)
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
declare namespace csd = "urn:ihe:iti:csd:2013";

declare
  %rest:path("/CSD/adapter")
  %rest:GET
  %output:method("xhtml")
  function page:show_types() 
{ 
  let $funcs := (csr_proc:stored_functions($csd_webconf:db), csr_proc:stored_updating_functions($csd_webconf:db))
  let $searches := 
    <ul>
      {
	for $adapter_func in $funcs[./csd:extension[@urn='urn:openhie.org:openinfoman:adapter']] 
        let $desc := $adapter_func/csd:description
        let $types := $adapter_func/csd:extension[@urn='urn:openhie.org:openinfoman:adapter']/@type
	let $uuid := string($adapter_func/@uuid)
	return 
	  for $type in $types
	  let $s_type := string($type)
	  return
  	  <li style='dispaly:block'>
	    <div class='container'>
	      <p>
	      Type (<a href="{$csd_webconf:baseurl}CSD/adapter/{$s_type}">{$s_type}</a>)
	      </p>
	      <p>
	      Adapter Document Index (
	      <a href="{$csd_webconf:baseurl}CSD/adapter/{$s_type}/{$uuid}">{$uuid}</a>
			       )
	      </p>
	      <p>
	      Adapter Document Source (
	      <a href="{$csd_webconf:baseurl}CSD/storedFunctions/download/{$uuid}">{$uuid}</a>
			       )
	      </p>
	      <div>

		<pre class='bodycontainer scrollable pull-left' style='overflow:scroll;font-family: monospace;white-space: pre;'>{string($desc)}</pre>
	      </div>
	    </div>
	  </li>
      }
    </ul>
  return csd_webconf:wrapper($searches)
};




declare
  %rest:path("/CSD/adapter/{$type}")
  %rest:GET
  %output:method("xhtml")
  function page:show_type($type) 
{ 
  let $funcs := (csr_proc:stored_functions($csd_webconf:db), csr_proc:stored_updating_functions($csd_webconf:db))[./csd:extension[@type = $type] ]
  let $adaptations := 
    <div>
      <h2>{$type}</h2>
      <ul>
        {
	    for $adapter_func in $funcs
            let $desc := $adapter_func/csd:description
	    let $uuid := string($adapter_func/@uuid)
	    return
  	    <li>
	      Type (<a href="{$csd_webconf:baseurl}CSD/adapter/{$type}">{$type}</a>)
	      <p>
	      Adapter Document Index (
	      <a href="{$csd_webconf:baseurl}CSD/adapter/{$type}/{$uuid}">{$uuid}</a>
			       )
	      </p>
	      <p>{$desc}</p>
	    </li>
	}
      </ul>
    </div>
  let $contents := 
    <div class='container'>
      <a href="{$csd_webconf:baseurl}CSD/adapter/">Adapters</a>
      {$adaptations}
    </div>
  return page:wrapper($contents)
};





declare function page:wrapper($response) {
 <html>
  <head>

    <link href="{$csd_webconf:baseurl}static/bootstrap/css/bootstrap.css" rel="stylesheet"/>
    <link href="{$csd_webconf:baseurl}static/bootstrap/css/bootstrap-theme.css" rel="stylesheet"/>
    

    <link rel="stylesheet" type="text/css" media="screen"   href="{$csd_webconf:baseurl}static/bootstrap-datetimepicker/css/bootstrap-datetimepicker.min.css"/>

    <script src="https://code.jquery.com/jquery.js"/>
    <script src="{$csd_webconf:baseurl}static/bootstrap/js/bootstrap.min.js"/>
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
    <div class="container">
      <h1>Adapters</h1>
      {$response}
    </div>
  </body>
 </html>
};


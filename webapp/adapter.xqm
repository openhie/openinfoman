module namespace page = 'http://basex.org/modules/web-page';

import module namespace csr_proc = "https://github.com/his-interop/openinfoman/csr_proc";
(:import module namespace csr_adpt = "https://github.com/his-interop/openinfoman/csr_adpt"; :)
import module namespace csd_webconf =  "https://github.com/his-interop/openinfoman/csd_webconf";
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
	for $adapter_func in $funcs[./csd:extension[@urn='urn:openhie.org:openinfoman:csr_adapter']] 
        let $desc := $adapter_func/csd:description
        let $type := string($adapter_func/csd:extension[@urn='urn:openhie.org:openinfoman:csr_adapter']/@type)
	let $uuid := string($adapter_func/@uuid)
	return
  	<li>
	   Type ({$type})
	   Adapter ID ({$uuid})
	   <p>{$desc}</p>
	   <a href="{$csd_webconf:baseurl}/CSD/adapter/{$type}/{$uuid}">{$uuid}</a>
	</li>
      }
    </ul>
  return page:wrapper($searches)
};




declare
  %rest:path("/CSD/adapter/{$type}")
  %rest:GET
  %output:method("xhtml")
  function page:show_type($type) 
{ 
  let $funcs := (csr_proc:stored_functions($csd_webconf:db), csr_proc:stored_updating_functions($csd_webconf:db))
  let $searches := 
    <div>
      <h2>{$type}</h2>
      <ul>
        {
	    for $adapter_func in $funcs/csd:extension[@urn='urn:openhie.org:openinfoman:csr_adapter' and @type = $type ]
            let $desc := $adapter_func/csd:description
            let $type := $adapter_func/csd:extension/@type
	    let $uuid := string($adapter_func/@uuid)
	    return
  	    <li>
	      Type ({$type})
	      Adapter ID ({$uuid})
	      <p>{$desc}</p>
	      <a href="{$csd_webconf:baseurl}/CSD/adapter/{$type}/{$uuid}">{$uuid}</a>
	    </li>
	}
      </ul>
    </div>
  return page:wrapper($searches)
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
    {$response}
  </body>
 </html>
};


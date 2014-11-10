module namespace page = 'http://basex.org/modules/web-page';

import module namespace csr_proc = "https://github.com/openhie/openinfoman/csr_proc";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
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
	let $urn := string($adapter_func/@urn)
	return 
	  for $type in $types
	  let $s_type := string($type)
	  return
  	  <li style='dispaly:block'>Stored Function <a href="{$csd_webconf:baseurl}/CSD/storedFunctions#{$urn}">{$urn}</a>
	    <div class='container'>
	      <p>
	      Type (<a href="{$csd_webconf:baseurl}CSD/adapter/{$s_type}">{$s_type}</a>)
	      </p>
	      <p>
		Act on a <a href="{$csd_webconf:baseurl}CSD/adapter/{$s_type}/{$urn}">Document</a>
	      </p>
	      <p>
	      </p>
	      <div>

		<pre class='bodycontainer scrollable pull-left' style='overflow:scroll;font-family: monospace;white-space: pre;'>{string($desc)}</pre>
	      </div>
	    </div>
	  </li>
      }
    </ul>
  return page:wrapper($searches)
};



declare
  %rest:path("/CSD/adapter/{$type}/{$search_name}")
  %output:method("xhtml")
  function page:show_endpoints($search_name,$type) 
{  
  let $function := csr_proc:get_any_function_definition($csd_webconf:db,$search_name)
  let $extensions :=  $function/csd:extension[@urn='urn:openhie.org:openinfoman:adapter' and  @type=$type]
       
  let $contents := 
    if (count($extensions) = 0)
      (:not a read fhir entity query. should 404 or whatever is required by FHIR :)
    then ("Not a " , $type , " compatible stored functions" )
    else 
      <div>
	<h2>{$type} Documents</h2>
	<h3>{string($function/@urn)}</h3>
        <ul>
          {
  	    for $doc_name in csd_dm:registered_documents($csd_webconf:db)      
	    return
  	    <li>
	      <a href="{$csd_webconf:baseurl}CSD/csr/{$doc_name}/careServicesRequest/{$search_name}/adapter/{$type}">{string($doc_name)}</a>
	    </li>
	  }
	</ul>
      </div>
  return csd_webconf:wrapper($contents)

 
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
	    let $urn := string($adapter_func/@urn)
	    return
  	    <li>
	      Type (<a href="{$csd_webconf:baseurl}CSD/adapter/{$type}">{$type}</a>)
	      <p>
		<a href="{$csd_webconf:baseurl}CSD/adapter/{$type}/{$urn}">Document Index</a> for {$urn}
	      </p>
	      <p>{$desc}</p>
	    </li>
	}
      </ul>
    </div>
  let $contents := 
    (
      <a href="{$csd_webconf:baseurl}CSD/adapter/">Adapters</a>
      ,$adaptations
      )
  return page:wrapper($contents)
};





declare function page:wrapper($response) {
  let $headers :=   
  (<link rel="stylesheet" type="text/css" media="screen"   href="{$csd_webconf:baseurl}static/bootstrap-datetimepicker/css/bootstrap-datetimepicker.min.css"/>
  , <script src="{$csd_webconf:baseurl}static/bootstrap-datetimepicker/js/bootstrap-datetimepicker.js"/>
  )

  return csd_webconf:wrapper($response,$headers)
};
 
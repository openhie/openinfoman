module namespace page = 'http://basex.org/modules/web-page';

import module namespace csr_proc = "https://github.com/openhie/openinfoman/csr_proc";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace csd_webui =  "https://github.com/openhie/openinfoman/csd_webui";
declare namespace csd = "urn:ihe:iti:csd:2013";

declare
  %rest:path("/CSD/adapter")
  %rest:GET
  %output:method("xhtml")
  function page:show_types() 
{ 
  let $funcs := (csr_proc:stored_functions($csd_webconf:db), csr_proc:stored_updating_functions($csd_webconf:db))
  let $types := distinct-values($funcs/csd:extension[@urn='urn:openhie.org:openinfoman:adapter']/@type)
  let $type_list := 
    <ul>
      {
      for $type in $types
      let $s_type := string($type)
      let $href := csd_webui:generateURL(("CSD/adapter/" , $s_type))
      return <li><a href="{$href}">{$s_type}</a></li>
      } 
    </ul> 
  return page:wrapper((<h3>Available Adapaters</h3>, $type_list))
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
	      <a href="{csd_webui:generateURL(('CSD/csr',$doc_name,'careServicesRequest',$search_name,'adapter',$type))}">{string($doc_name)}</a>
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
	      Type (<a href="{csd_webui:generateURL(('CSD/adapter/',$type))}">{$type}</a>)
	      <p>
		<a href="{csd_webui:generateURL(('CSD/adapter/',$type,$urn))}">Document Index</a> for {$urn}
	      </p>
	      <p>{$desc}</p>
	    </li>
	}
      </ul>
    </div>
  let $contents := 
    (
      <a href="{csd_webui:generateURL('CSD/adapter')}">Adapters</a>
      ,$adaptations
      )
  return page:wrapper($contents)
};





declare function page:wrapper($response) {
  let $headers :=   
  (<link rel="stylesheet" type="text/css" media="screen"   href="{csd_webui:generateURL('static/bootstrap-datetimepicker/css/bootstrap-datetimepicker.min.css')}"/>
  , <script src="{csd_webui:generateURL('static/bootstrap-datetimepicker/js/bootstrap-datetimepicker.js')}"/>
  )

  return csd_webconf:wrapper($response,$headers)
};
 
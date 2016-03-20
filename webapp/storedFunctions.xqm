module namespace page = 'http://basex.org/modules/web-page';

import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace csd_webui =  "https://github.com/openhie/openinfoman/csd_webui";
import module namespace csr_proc = "https://github.com/openhie/openinfoman/csr_proc";
declare   namespace   xforms = "http://www.w3.org/2002/xforms";
declare namespace xs = "http://www.w3.org/2001/XMLSchema";
declare   namespace   csd = "urn:ihe:iti:csd:2013";
declare default element  namespace   "urn:ihe:iti:csd:2013";

declare variable $page:xsl := "../resources/doc_careServiceFunctions.xsl";

declare
  %rest:path("/CSD/storedFunctions")
  %rest:GET
  %output:method("xhtml")
  function page:csr_list() 
{ 
  let $content:= <span>
    <h2>Registered Stored Queries</h2>
    <ul>
      <li>{count(csr_proc:stored_functions())} Stored Functions <br/></li>
      <li>{count(csr_proc:stored_updating_functions())} Stored Updating Functions <br/></li>

      <li>    <a href="{csd_webui:generateURL('CSD/storedFunctions/export_doc')}">Export Documentation</a></li>
      <li><a href="{csd_webui:generateURL('CSD/storedFunctions/export_funcs')}">Export Functions</a></li>
      <li><a href="{csd_webui:generateURL('CSD/storedFunctions/clear')}">Clear All Stored Functions</a></li>
    </ul>
  </span>
  let $list := page:function_list()
  return csd_webui:wrapper(($content,$list))
};



declare  updating 
  %rest:path("/CSD/storedFunctions/delete/{$urn}")
  function page:delete($urn) 
  {
    (
      csr_proc:delete_stored_function($urn),
      csd_webui:redirect_out("CSD/storedFunctions")
    )

};

declare
  %rest:path("/CSD/storedFunctions/download/{$urn}")
  function page:download($urn) 
  {
    let $node := (
      csr_proc:get_function_definition($urn),
      csr_proc:get_updating_function_definition($urn)
    )[1]
    return $node
    

};


declare  updating 
  %rest:path("/CSD/storedFunctions/clear")
  function page:clear() 
  {
    (
      csr_proc:clear_stored_functions(),
      csd_webui:redirect_out("CSD/storedFunctions")
    )

};


declare function page:display_function($function,$updating) {
  let  $urn := string($function/@urn)
  return  <span id="{$function/@urn}">
    {if ($updating) then  "(Updating) " else ()}
    URN: {string($urn)}  <br/>
    Method: <blockquote><pre>{string($function/definition)} </pre></blockquote>
    Content: {string(csr_proc:lookup_stored_content_type($urn)) } <br/>
    Description: <blockquote>{$function/description}</blockquote>
    Instance:   <blockquote><pre>{serialize($function/xforms:instance/careServicesRequest,map{'indent':'yes'})} </pre></blockquote>
    {if (exists($function/@method)) then  ("Method: ",string($function/@method),<br/>) else () }
    {if (exists($function/xs:schema)) then  ("Schema: ",string($function/xs:schema),<br/>) else () }
    {if (count( $function/xforms:bind) > 0) then
    ("Bindings: ",
    <blockquote>
      <ul>
        {for $bind in $function/xforms:bind return <li><b>Node set</b>: {string($bind/@nodeset)} <br/><b>Type</b>: {string($bind/@type)}</li>}
      </ul>
    </blockquote>
    ) else () 
    }
  </span>
};

declare 
  %rest:path("/CSD/storedFunctions/export_funcs")
  %rest:GET
  function page:export_funcs() 
{
  <careServiceFunctions 
    xmlns:xforms="http://www.w3.org/2002/xforms" 
    xmlns:csd="urn:ihe:iti:csd:2013" 
    xmlns:xi="http://www.w3.org/2001/XInclude" 
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:hfp="http://www.w3.org/2001/XMLSchema-hasFacetAndProperty" 
     >
  {(
    csr_proc:stored_functions()
    ,csr_proc:stored_updating_functions()
   )}
 </careServiceFunctions>
};

declare 
  %rest:path("/CSD/storedFunctions/export_doc")
  %rest:GET
  %output:method("xhtml")
  function page:export_doc() 
{
  let $funcs := 
  <careServiceFunctions 
    xmlns:xforms="http://www.w3.org/2002/xforms" 
    xmlns:csd="urn:ihe:iti:csd:2013" 
    xmlns:xi="http://www.w3.org/2001/XInclude" 
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:hfp="http://www.w3.org/2001/XMLSchema-hasFacetAndProperty" 
     >
  {(
    csr_proc:stored_functions()
    ,csr_proc:stored_updating_functions()
   )}
 </careServiceFunctions>
(: return $funcs :)
 return xslt:transform($funcs,doc($page:xsl))   
};


declare function page:function_list()  {
  <span>
    <h2>Function List</h2>
    <ul>
    {
      for $function in (csr_proc:stored_functions(),csr_proc:stored_updating_functions())
      return  
      <li>URN: {string($function/@urn)} {"  "}
      <i>
	{substring(string($function/description),1,100)}
	{if (string-length(string($function/description)) > 100) then "..." else ()}
      </i>
      <br/>
      <a href="#{$function/@urn}">View</a>
      <a href="{csd_webui:generateURL(('CSD/storedFunctions/download',$function/@urn))}">Download</a>
      <a href="{csd_webui:generateURL(('CSD/storedFunctions/delete/',$function/@urn))}" onClick="return confirm('This will remove the ability to execute this function. are you sure?');">Delete</a>
      </li>
    }
    </ul>

    <ul>
    {
      (
	for $function in csr_proc:stored_functions()
	return   <li>{page:display_function($function,false())}</li>
       ,
        for $function in csr_proc:stored_updating_functions()
        return  <li>{page:display_function($function,true())}</li>
      )
    }
    </ul>
  </span>
};


declare 
  %rest:path("/CSD/storedFunctions.json")
  %rest:GET
  function page:export_function_details_json()
  {    
  xml-to-json(page:get_export_function_details())
  };

declare 
  %rest:path("/CSD/storedFunctions.xml")
  %rest:GET
  function page:export_function_details_xml(){
    page:get_export_function_details()
};

declare function page:get_export_function_details() {
    <map xmlns="http://www.w3.org/2005/xpath-functions">
      {
	for $function in (csr_proc:stored_functions())
	let $urn:= string($function/@urn)
	return  
	<map key="{$urn}">
	  <boolean key="updating">false</boolean>
	  <string key="description">{string($function/description)}</string>
	  <string key="definition">{string($function/definition)}</string>
	  <string key="content-type">{string(csr_proc:lookup_stored_content_type($urn))}</string>
	</map>
      }
      {
	for $function in (csr_proc:stored_updating_functions())
	let $urn:= string($function/@urn)
	return  
	<map key="{string($function/@urn)}">
	  <boolean key="updating">true</boolean>
	  <string key="description">{string($function/description)}</string>
	  <string key="definition">{string($function/definition)}</string>
	  <string key="content-type">{string(csr_proc:lookup_stored_content_type($urn))}</string>
	</map>
      
      }
    </map>
};









 

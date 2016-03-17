module namespace page = 'http://basex.org/modules/web-page';

import module namespace csr_proc = "https://github.com/openhie/openinfoman/csr_proc";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace csd_webui =  "https://github.com/openhie/openinfoman/csd_webui";


declare   namespace   csd = "urn:ihe:iti:csd:2013";
declare default element  namespace   "urn:ihe:iti:csd:2013";

declare variable $page:csd_docs := csd_dm:registered_documents($csd_webconf:db);

declare
  %rest:path("/CSD/csr/{$name}/careServicesRequest")
  %rest:POST("{$careServicesRequest}")
  function page:csr($name,$careServicesRequest) 
{ 
  if (csd_dm:document_source_exists($csd_webconf:db,$name)) then 
    try {
       csr_proc:process_CSR($csd_webconf:db,$careServicesRequest/careServicesRequest,$name,csd_webui:generateURL())
    } catch * {
       <rest:response>
         <http:response status="422" message="Error executing xquery.">
           <http:header name="Content-Language" value="en"/>
           <http:header name="Content-Type" value="text/html; charset=utf-8"/>
         </http:response>
       </rest:response>
    }
  else
       <rest:response>
         <http:response status="404" message="No document named {$name} exists">
           <http:header name="Content-Language" value="en"/>
           <http:header name="Content-Type" value="text/html; charset=utf-8"/>
         </http:response>
       </rest:response>

};


declare updating
  %rest:path("/CSD/csr/{$name}/careServicesRequest/update")
  %rest:consumes("application/xml", "text/xml", "multipart/form-data")  
  %rest:POST("{$careServicesRequest}")
  function page:csr_updating($name,$careServicesRequest) 
{ 
  if (csd_dm:document_source_exists($csd_webconf:db,$name)) then 
    try {
       csr_proc:process_updating_CSR($csd_webconf:db,$careServicesRequest/csd:careServicesRequest,$name,csd_webui:generateURL())
    } catch * {
      db:output(  
       <rest:response>
         <http:response status="422" message="Error executing xquery.">
           <http:header name="Content-Language" value="en"/>
           <http:header name="Content-Type" value="text/html; charset=utf-8"/>
         </http:response>
       </rest:response>
       )
    }
  else
    db:output(
       <rest:response>
         <http:response status="404" message="No document named {$name} exists">
           <http:header name="Content-Language" value="en"/>
           <http:header name="Content-Type" value="text/html; charset=utf-8"/>
         </http:response>
       </rest:response>
     )
};



declare
  %rest:path("/CSD/csr/{$name}/adhoc")
  %rest:consumes("application/xml", "text/xml", "multipart/form-data")
  %rest:POST
  %rest:form-param("adhoc","{$adhoc}")
  %rest:form-param("content", "{$content}","application/xml")
function page:adhoc($name,$adhoc,$content) {    
  if (csd_dm:document_source_exists($csd_webconf:db,$name)) then 
    try {
      let  $adhoc_doc := csr_proc:create_adhoc_doc(string($adhoc),$content)
      return  csr_proc:process_CSR($csd_webconf:db, $adhoc_doc,$name,csd_webui:generateURL())
    } catch * {
       <rest:response>
         <http:response status="422" message="Error executing xquery.">
           <http:header name="Content-Language" value="en"/>
           <http:header name="Content-Type" value="text/html; charset=utf-8"/>
         </http:response>
       </rest:response>
    }
  else
       <rest:response>
         <http:response status="404" message="No document named {$name} exists">
           <http:header name="Content-Language" value="en"/>
           <http:header name="Content-Type" value="text/html; charset=utf-8"/>
         </http:response>
       </rest:response>

};



declare
  %rest:path("/CSD/csr")
  %rest:GET
  %output:method("xhtml")
  function page:csr_list() 
{ 
let $response := page:endpoints()
return csd_webui:wrapper($response)
};


declare
  %rest:path("/CSD/csr/{$name}/careServicesRequest")
  %rest:GET
  %output:method("xhtml")
  function page:csr($name)
{
  let $contents :=
    (
    <p>
      Example Usage:
      <pre>curl -X POST -H 'content-type: text/xml'  --data-binary @request.xml $URL</pre>
      where $URL is one of the below and request.xml is an XML file containing a &lt;csd:requestParams/&gt; element
    </p>
    ,
    <ul>{
    (
      for $function in csr_proc:stored_functions($csd_webconf:db)
      let $url := csd_webui:generateURL(("CSD/csr", $name , "careServicesRequest", string($function/@urn)))
      return
      <li>
          <p>Name: {string($function/@urn)}</p>
	  <p>URL: {$url}</p>
      	  <p><a href="{csd_webui:generateURL(concat('CSD/storedFunctions#',$name))}">Full Description</a></p>
      </li>
      ,
      for $function in csr_proc:stored_updating_functions($csd_webconf:db)
      let $url := csd_webui:generateURL(("CSD/csr", $name , "careServicesRequest/update", string($function/@urn)))
      return
      <li>
          <p>Name: {string($function/@urn)} (updating)</p>
	  <p>URL: {$url}</p>
	  <p><a href="{csd_webui:generateURL(concat('CSD/storedFunctions#',$name))}">Full Description</a></p>
      </li>
    )
    }</ul>
    )
  return csd_webui:wrapper($contents)
};


declare
  %rest:path("/CSD/csr/{$name}/storedfunctions")
  %rest:GET
  %output:method("xhtml")
  function page:show_type($name) 
{ 
  let $funcs := (csr_proc:stored_functions($csd_webconf:db), csr_proc:stored_updating_functions($csd_webconf:db))
  let $options :=
    for $func in $funcs
    let $urn := string($func/@urn)
    let $val := csd_webui:generateURL(('/CSD/csr',$name,'careServicesRequest',$urn))
    return <option value="{$val}">{$urn}</option>

      
   let $content := 
     <span>
       <script type='text/javascript'><![CDATA[
$(function() {	
    var form = $("#storedfunc");
    var sel = form.find('select[name=func]');
    var val = sel.find('option:selected').val();
    form.attr('action',val);

    sel.change( function() {
      var val = sel.find('option:selected').val();
      form.attr('action',val);
    });

    form.submit( function( event ) {
	event.preventDefault();
        var data = form.find('textarea[name=requestParams]').val();
        var url = form.attr('action');
        var resp = form.find('#response');
	$.ajax({
		method:'POST',
		type: 'POST',
		url:url,
		data:data,
		contentType: 'text/xml',
		dataType: "xml",
		cache: false,
		error: function(xhr,status,error) {
		    alert('Failed To Send Data To ILR');
		},
		success: function(xml) { 
                    var text =(new XMLSerializer()).serializeToString(xml); 
                    console.log(text);
                    resp.text(text);
		}
	    });
     });

});
]]>
       </script>

       <h2>Submit stored function:</h2>
       <form id='storedfunc' method='post' action=""  enctype="multipart/form-data">
         
	 <p><label for="func">Stored Function</label>	 </p>
	 <select name="func">{$options}</select>
	 <br/>
	 <p><label for="requestParms">Request Paramaters</label>	 </p>
	 <textarea  rows="10" cols="80" name="requestParams" ><![CDATA[<csd:requestParams xmlns:csd='urn:ihe:iti:csd:2013'/>]]></textarea>
	 <br/>
	 <input type="submit" value="submit"/>
         <br/>
         <h2>Response</h2>
         <textarea id='response' rows="50"  style='width:100%'/>
       </form>   
     </span>

  return csd_webui:wrapper($content)

};





declare function page:endpoints() {
<span>
    <h2>Care Services Request - Endpoints</h2>
    <ul>
      {
	for $name in $page:csd_docs
	return 
	<li> 
        <h4>{$name} Document </h4>
        <ul>
	  <li>
	     <a href="{csd_webui:generateURL(('/CSD/csr',$name,'storedfunctions'))}">Individual Stored functions</a>
	  </li>
	  <li>
	    Submit Care Services Request for {$name} at:
	    <pre>{csd_webui:generateURL(('CSD/csr/',$name,'/careServicesRequest'))}</pre> 
	  </li>
	  <li>
	    Submit ad-hoc query:
	    <form method='post' action="{csd_webui:generateURL(('/CSD/csr',$name,'adhoc'))}"  enctype="multipart/form-data">
	      <label for="adhoc">Ad-Hoc Query</label><textarea  rows="10" cols="80" name="adhoc" >{$page:sample}</textarea>
	      <br/>
	      <label for="content">Content Type</label><input    cols="80" name="content" value="text/html"/>
	      <br/>
	      <input type="submit" value="submit"/>
	    </form>
	  </li>
        </ul>
	</li>
      }
    </ul>
  </span>
};






declare variable $page:sample := 
"declare namespace csd = 'urn:ihe:iti:csd:2013';
<html>
 <body>
  <ul>
   <li>You have {count(/csd:CSD/csd:providerDirectory/*)} providers.</li>
   <li>You have {count(/csd:CSD/csd:facilityDirectory/*)} facilities.</li>
   <li>You have {count(/csd:CSD/csd:organizationDirectory/*)} organizations.</li>
   <li>You have {count(/csd:CSD/csd:serviceDirectory/*)} services.</li>
  </ul>
 </body>
</html>";





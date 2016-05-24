declare namespace csd  =  "urn:ihe:iti:csd:2013";
declare namespace xforms = "http://www.w3.org/2002/xforms";
declare namespace soap = "http://www.w3.org/2003/05/soap-envelope";
declare namespace wsa = "http://www.w3.org/2005/08/addressing";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace http = "http://expath.org/ns/http-client";
declare namespace file = "http://expath.org/ns/file";

declare variable $file as item() external;


(:
Usage Example:
 basex  -w -b "file=/Users/litlfred/pulsar_cats/openinfoman-hwr//resources/stored_query_definitions/health_worker_read_address.xml"   update_cp_926.xq  


:)

copy $sf := fetch:xml($file, map { 'xinclude': false() })/csd:careServicesFunction
modify (
  let $id := $sf/@urn
  let $xfi := 
    <csd:requestParams>
{      $sf/xforms:instance/(csd:careServicesRequest,careServicesRequest)/* }
    </csd:requestParams>
  let $xfbs := $sf/xforms:bind
  let $xfks := $sf/xforms:schema
  let $xfss := $sf/xforms:submission

  let $model := 
    <xforms:model id="{$id}">
       <xforms:instance id='care-services-result'>
	 <csd:careSerivcesResponse id="" code="" content-type=""/>
       </xforms:instance>

       <xforms:instance id='http-post-request'>       
	 {$xfi}
       </xforms:instance>

       <xforms:instance id="http-post-response" >
         <http:result status="">
	   <http:header name="X-CSD-Transaction-ID" value=""/>
	   <http:body/>
	 </http:result>
       </xforms:instance>

       <xforms:instance id='soap-request'>
	 <soap:Envelope >  
	   <soap:Header>
	     <wsa:Action soap:mustUnderstand="1">urn:ihe:iti:csd:2013:GetCareServicesRequest</wsa:Action>
             <wsa:MessageID/>
             <wsa:ReplyTo soap:mustUnderstand="1">
               <wsa:Address>http://www.w3.org/2005/08/addressing/anonymous</wsa:Address>
             </wsa:ReplyTo>
             <wsa:To soap:mustUnderstand="1">{{$LOCATION}}</wsa:To>
	   </soap:Header>
	   <soap:Body>
	     <csd:careServicesRequest  urn="{$id}">
		 {$xfi}
	     </csd:careServicesRequest>         
	   </soap:Body>
	 </soap:Envelope>
       </xforms:instance>

       <xforms:instance id="soap-response" >
	 <soap:Envelope>
	   <soap:Header>
	     <wsa:Action soap:mustUnderstand="1">urn:ihe:iti:csd:2013:GetCareServicesResponse</wsa:Action>
             <wsa:MessageID/>
             <wsa:ReplyTo soap:mustUnderstand="1">
               <wsa:Address>http://www.w3.org/2005/08/addressing/anonymous</wsa:Address>
             </wsa:ReplyTo>
	     <wsa:RelatesTo/>
	   </soap:Header>
	   <soap:Body>
	     <csd:careServicesResponse/>
	   </soap:Body>
	 </soap:Envelope>
       </xforms:instance>

       {$xfks}

       
       <xforms:submission 
         id="soap-submission" 
	 method="post" 
	 mediatype="application/soap+xml"
	 ref="instance('soap-request')"
	 resource="{{$LOCATION}}" />		       

       <xforms:submission 
         id="http-post-submission" 
	 method="post" 
	 mediatype="text/xml"
	 ref="instance('http-post-request')"
	 resource="{{$LOCATION}}/{$id}" />

       <xforms:action ev:event="xforms-submit-done" id="http-post-prepare" >
	 <xforms:insert 
	 context="instance('http-post-response')/http:result/http:body"
	 origin="instance('care-services-result')/csd:careServicesResponse/csd:result/*"
	 />
	 <xforms:setValue 
	 bind="instance('http-post-response')/http:result/@status" 
	 value="instance('care-services-result')/csd:careServicesResponse/@code"
	 />
	 <xforms:setValue 
	 bind="instance('http-post-response')/http:body/@content-type" 
	 value="instance('care-services-result')/csd:careServicesResponse/@content-type"
	 />
	 <xforms:setValue 
	 bind="instance('http-post-response')/http:result/http:header[@name='X-CSD-Transaction-ID']/@value"
	 value="instance('care-services-result')/csd:careServicesResponse/@id"
	 />
       </xforms:action>


       <xforms:action ev:event="xforms-submit-done" id="soap-prepare"> 	    
	 <xforms:insert 
	 context="instance('soap-response')/soap:Envelope/soap:Body/csd:careServicesResponse/csd:result"
	 origin="instance('care-services-result')/csd:careServicesRepsonse/csd:result/*"
	 />
	 <xforms:insert 
	 context="instance('soap-response')/soap:Envelope/soap:Body/csd:careServicesResponse/@content-type"
	 origin="instance('care-services-result')/csd:careServicesRepsonse/@content-type"
	 />
	 <xforms:insert 
	 context="instance('soap-response')/soap:Envelope/soap:Body/csd:careServicesResponse/@code"
	 origin="instance('care-services-result')/csd:careServicesRepsonse/@code"
	 />
	 <xforms:setValue 
	 bind="instance('soap-response')/soap:Envelope/soap:Header/wsa:messageID" 
	 value="instance('soap-request')/csd:careServicesRequest/@id"
	 />
	 <xforms:setValue 
	 bind="instance('soap-response')/soap:Envelope/soap:Header/wsa:relatesTo" 
	 value="instance('soap-request')/soap:Envelope/soap:Header/wsa:messageID"
	 />
       </xforms:action>


       {
	 for $xfb in $xfbs
	 let $pns := concat("instance('http-post-request')/",$xfb/@nodeset/text())
	 let $sns := concat("instance('soap-request')/soap:Envelope/soap:Header/soap:Body/csd:careServicesRequest/",$xfb/@nodeset/text())
	 return
	   (
	   <xforms:bind nodeset="{$pns}" type="{$xfb/@type}"/>
	   ,
	   <xforms:bind nodeset="{$sns}" type="{$xfb/@type}"/>
	   )
       }              

       {$xfss}
    </xforms:model>
  return insert node $model after $sf /csd:definition

    ,
    for $e in ( $sf/xforms:instance, $sf/xforms:bind ,  $sf/xforms:schema)
    return delete node $e
    
)

return file:write($file,$sf)
  

module namespace page = 'http://basex.org/modules/web-page';
import module namespace csd = "urn:ihe:iti:csd:2013" at "../repo/csd_base_library.xqm";
import module namespace csd_proc = "https://github.com/his-interop/openinfoman" at "../repo/csd_processor.xqm";


declare variable $page:doc_tests := 
<tests>
   <test name='provider_search_by_id' doc='providers.xml' db='provider_directory'>
     <csd:careServicesRequest xmlns:csd='urn:ihe:iti:csd:2013' xmlns='urn:ihe:iti:csd:2013'>
       <function uuid='4e8bbeb9-f5f5-11e2-b778-0800200c9a66'>
	 <requestParams>
	   <id oid='2.25.309768652999692686176651983274504471835.646.1.615351552068889518564164611046405512878087'/>
	   <otherID/>
	   <commonName/>
	   <type/>
	   <addressLine/>
	   <record/>
	   <start/>
	   <max/>
	 </requestParams>
       </function>
     </csd:careServicesRequest>     
   </test>
   <test name='invalid_search' doc='providers.xml' db='provider_directory'>
     <csd:careServicesRequest xmlns:csd='urn:ihe:iti:csd:2013' xmlns='urn:ihe:iti:csd:2013'>
       <function uuid='blah blah invalid'>
	 <requestParams/>
       </function>
     </csd:careServicesRequest>     
   </test>
</tests>;


declare
  %rest:path("/CSD/test/{$test}")
  %rest:GET
  function page:test(
    $test as xs:string)
{
let $doc_test := $page:doc_tests/test[@name=$test]
let $careServicesRequest := $doc_test/csd:careServicesRequest

for $doc in collection($doc_test/@db)
where matches(document-uri($doc), $doc_test/@doc) 

return csd_proc:process_CSR($careServicesRequest,$doc)

};

declare
  %rest:path("/CSD/test_source/{$test}")
  %rest:GET
  %output:method("xml")
  function page:test_source(
    $test as xs:string)
{
let $doc_test := $page:doc_tests/test[@name=$test]
let $careServicesRequest := $doc_test/csd:careServicesRequest
return $careServicesRequest

};



declare 
  %rest:path("/CSD/test")
  %rest:GET
  %output:method("xhtml")
  function page:list_tests() 
{
<html>
  <body>
    <h2>Tests</h2>
    <div id='result'/>
    <ul>
        {for $test in $page:doc_tests/test
         return  <li>
			{text{$test/@name}} 
			<a href="test/{text{$test/@name}}"> (process on server)</a> 
			<a href="test_source/{text{$test/@name}}"> (see source doc)</a> 
 		  </li>
        }
    </ul>
  </body>
</html>
};
  


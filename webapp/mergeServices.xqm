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





declare
  %rest:path("/CSD/mergeServices")
  %rest:GET
  %output:method("xhtml")
  function page:merge_menu()
{ 
  let $response:=
  <div>
    <div class='container'>
      <div class='row'>
 	<div class="col-md-8">
	  <h2>Merge Cached Service Directories - Simple Join</h2>
	  <form action="/CSD/mergeServices/merge">
	    {
	      let $docs := csd_dm:registered_documents($csd_webconf:db)
              return 
		<span>
		  <label for='dest'>Destination Document</label>
		  <select name='dest'>
		    <option value=''>Select A Value</option>
		    {
		      for $doc in $docs
		      return <option value="{$doc}">{$doc}</option>
		    }
		  </select>
		  <br/>
		  {
		    for $doc in $docs
		    return (<input type='checkbox'  name="merge" value="{$doc}">{$doc}</input>,<br/>)
		  }
		 		  
		  <br/>
		  <input type='submit' value='Merge'/>
		</span>
	    }
	  </form>
	</div>
      </div>
    </div>
  </div>
  
  return csd_webconf:wrapper($response)

};



declare updating
  %rest:path("/CSD/mergeServices/merge")
  %rest:GET
  %rest:query-param("merge", "{$merge}")
  %rest:query-param("dest", "{$dest}")
  function page:merge($dest,$merge)
{ 
  
  csd_mcs:merge($csd_webconf:db,$dest,$merge)
  ,
  db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/mergeServices")))
};


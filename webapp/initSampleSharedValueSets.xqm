module namespace page = 'http://basex.org/modules/web-page';

import module namespace svs_lsvs = "https://github.com/openhie/openinfoman/svs_lsvs";
declare namespace svs = "urn:ihe:iti:svs:2008";
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





declare updating   
  %rest:path("/CSD/SVS/initSampleSharedValueSet/init")
  %rest:GET
  function page:init()
{ 
(
  svs_lsvs:init_store($csd_webconf:db),
  db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/SVS/initSampleSharedValueSet")))
)
};




declare
  %rest:path("/CSD/SVS/initSampleSharedValueSet/svs/{$id}")
  %rest:GET
  %output:method("xhtml")
  function page:get_svs_menu($id)
{
  let $response := page:svs_menu($id) 
  return page:nocache(csd_webconf:wrapper($response))
};



declare
  %rest:path("/CSD/SVS/RetrieveMultipleValueSets")
  %rest:GET
  %rest:query-param("ID", "{$ID}")
  %rest:query-param("DisplayNameContains" ,"{$DisplayNameContains}",'')
  %rest:query-param("SourceContains" ,"{$SourceContains}",'')
  %rest:query-param("PurposeContains" ,"{$PurposeContains}",'')
  %rest:query-param("DefinitionContains" ,"{$DefinitionContains}",'')
  %rest:query-param("GroupContains" ,"{$GroupContains}",'')
  %rest:query-param("GroupOID" ,"{$GroupOID}",'')
  %rest:query-param("EffectiveDateBefore" ,"{$EffectiveDateBefore}",'')
  %rest:query-param("EffectiveDateAfter"  ,"{$EffectiveDateAfter}",'')
  %rest:query-param("ExpirationDateBefore" ,"{$ExpirationDateBefore}",'')
  %rest:query-param("ExpirationDateAfter" ,"{$ExpirationDateAfter}",'')
  %rest:query-param("CreationDateBefore" ,"{$CreationDateBefore}",'')
  %rest:query-param("CreationDateAfter" ,"{$CreationDateAfter}",'')
  %rest:query-param("RevisionDateBefore" ,"{$RevisionDateBefore}",'')
  %rest:query-param("RevisionDateAfter" ,"{$RevisionDateAfter}",'')
  function page:get_shared_value_set(
    $ID,$DisplayNameContains,$SourceContains,$PurposeContains,$DefinitionContains,$GroupContains,$GroupOID,
    $EffectiveDateBefore,$EffectiveDateAfter,$ExpirationDateBefore,$ExpirationDateAfter,
    $CreationDateBefore,$CreationDateAfter,$RevisionDateBefore,$RevisionDateAfter)
{ 
let $filter := <RetrieveMultipleValueSetsRequest
 ID="{$ID}"
 DisplayNameContains="{$DisplayNameContains}"
 SourceContains="{$SourceContains}"
 PurposeContains="{$PurposeContains}"
 DefinitionContains="{$DefinitionContains}"
 GroupContains="{$GroupContains}"
 GroupOID="{$GroupOID}"
 EffectiveDateBefore="{$EffectiveDateBefore}"
 EffectiveDateAfter="{$EffectiveDateAfter}"
 ExpirationDateBefore="{$ExpirationDateBefore}"
 ExpirationDateAfter="{$ExpirationDateAfter}"
 CreationDateBefore="{$CreationDateBefore}"
 CreationDateAfter="{$CreationDateAfter}"
 RevisionDateBefore="{$RevisionDateBefore}"
 RevisionDateAfter="{$RevisionDateAfter}"
/>
return svs_lsvs:get_multiple_described_value_sets($csd_webconf:db,$filter) 
};


(:ValueSet have @id while DesribedValueSet has @ID:)
declare
  %rest:path("/CSD/SVS/RetrieveValueSet")
  %rest:GET
  %rest:query-param("ID", "{$id}",'')
  %rest:query-param("lang", "{$lang}",'') 
  %rest:query-param("version", "{$version}",'')
  function page:get_single_version_value_set($id,$version,$lang)
{
  svs_lsvs:get_single_version_value_set($csd_webconf:db,$id,$version,$lang) 
};





declare updating   
  %rest:path("/CSD/SVS/initSampleSharedValueSet/svs/{$id}/load")
  %rest:GET
  function page:load($id)
{ 
(
  svs_lsvs:load($csd_webconf:db,$id)   ,
  db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/SVS/initSampleSharedValueSet")))
)
};


declare updating   
  %rest:path("/CSD/SVS/initSampleSharedValueSet/svs/{$id}/reload")
  %rest:GET
  function page:reload($id)
{ 
(
  svs_lsvs:reload($csd_webconf:db,$id)   ,
  db:output(page:redirect(concat($csd_webconf:baseurl,"CSD/SVS/initSampleSharedValueSet")))
)
};

declare
  %rest:path("/CSD/SVS/initSampleSharedValueSet/svs/{$id}/lookup")
  %rest:GET
  %rest:query-param("code","{$code}")
  %rest:query-param("lang", "{$lang}",'')
  %rest:query-param("version", "{$version}",'')
  %output:method("xhtml")
  function page:lookup_code($id,$code,$version,$lang) 
{
  let $response :=
  (<h2>Code: {$code}</h2>,

  for $concept in svs_lsvs:get_single_version_code($csd_webconf:db,$code,$id,$version,$lang)
  let $code_list := $concept/..
  let $value_set := $code_list/..
  return <span>
    <h3>Value Set: {text{$id}} ({text{$value_set/@displayName}}), ({text{$value_set/@version}})</h3>
    <ul>
      <li>displayName: {text{$concept/@displayName}}</li>
      <li>codeSystem: {text{$concept/@codeSystem}}</li>
    </ul>
    <a href="{$csd_webconf:baseurl}CSD/SVS/initSampleSharedValueSet/">Return</a>
  </span>
  )
  return csd_webconf:wrapper($response)
};


declare function page:wrapper_double($responseA,$responseB) {
 let $content := 
 <div class='row'>
   <div class="col-md-6">
     {$responseA}
   </div>
   <div class="col-md-4">
     {$responseB}
   </div>
 </div>
 return csd_webconf:wrapper($content)
};

declare
  %rest:path("/CSD/SVS/initSampleSharedValueSet")
  %rest:GET
  %output:method("xhtml")
  function page:svs_list()
{
if (not(svs_lsvs:store_exists($csd_webconf:db))) then
    page:redirect(concat($csd_webconf:baseurl,"/CSD/SVS/initSampleSharedValueSet/init"))
else 
 page:nocache( page:wrapper_double(
    <span >
      <h2>Shared Value Sets</h2>
      <p>
      FILES:
      {svs_lsvs:get_sample_value_set_list()}
      </p>
      <p>
      {svs_lsvs:get_all_value_set_list($csd_webconf:db)}
      </p>
      <ul>
	{for $set in svs_lsvs:get_all_value_set_list($csd_webconf:db)//svs:DescribedValueSet
	(:ValueSet have @id while DesribedValueSet has @ID:)
	let $id := text{$set/@ID}
	let $displayName := text{$set/@displayName}
	order by $set/@ID
	return 
	<li>
	  <a href="/CSD/SVS/initSampleSharedValueSet/svs/{$id}">{$displayName} ({$id})</a>
	  <br/>
	  {page:svs_menu($id)}
	</li>
	}
      </ul>
    </span>
    ,
    <span>
      <h2>Retrieve Multiple</h2>
      <form action="/CSD/SVS/RetrieveMultipleValueSets">
	<ul>
	  <li>ID: <input name="ID"/></li>
	</ul>
	<input type="submit" value="search"/>
      </form>
    </span>
	       )

      )

};



declare function page:svs_menu($id) {
  let $lang := ''
  let $version := ''
  let $set := svs_lsvs:get_all_value_set_list($csd_webconf:db)//svs:DescribedValueSet[@ID = $id]
  return 
    if (not($set)) then (<b>{$set}</b>) else 
      let $disp := text{$set/@displayName}
      return <ul>
	{if ($set/@file) then
	  if (not(svs_lsvs:exists($csd_webconf:db,$id))) then
          <li><a href="/CSD/SVS/initSampleSharedValueSet/svs/{$id}/load">Initialize {$id} ({$disp})</a> </li>
          else 
	  (
	  <li><a href="/CSD/SVS/RetrieveValueSet?ID={$id}">Get {$id}</a></li>,
	  <li><a href="/CSD/SVS/initSampleSharedValueSet/svs/{$id}/reload">Reload {$id}</a></li>,
	  <li><form action="/CSD/SVS/initSampleSharedValueSet/svs/{$id}/lookup"><label for="code">Lookup Code</label><input name="code" type="text"/><input type="submit"/></form></li>
	  )
        else
	  (:not @file so its not something we can load/reload :)
	  (
	  <li><a href="/CSD/SVS/RetrieveValueSet?ID={$id}">Get {$id}</a></li>,
	  <li><form action="/CSD/SVS/initSampleSharedValueSet/svs/{$id}/lookup"><label for="code">Lookup Code</label><input name="code" type="text"/><input type="submit"/></form></li>
	  )
	  }
       </ul>

};




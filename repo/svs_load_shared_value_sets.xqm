(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/openhie/openinfoman
:
:)
module namespace svs_lsvs = "https://github.com/openhie/openinfoman/svs_lsvs";

import module namespace functx = "http://www.functx.com";
declare namespace svs = "urn:ihe:iti:svs:2008";

(:WARNING: ValueSet have @id while DesribedValueSet has @ID:)


declare variable $svs_lsvs:vers := "1.1";
declare variable $svs_lsvs:base_path := concat(file:current-dir() ,'../resources/shared_value_sets/');
declare variable $svs_lsvs:valuesets_doc := "DescribedSharedValueSets.xml";
declare variable $svs_lsvs:sample_value_set_list := svs_lsvs:get_sample_value_set_list();
declare variable $svs_lsvs:blank_valuesets :=  <DescribedValueSets version="{$svs_lsvs:vers}"/>;

declare variable $svs_lsvs:remote_value_sets := 'remote_value_sets.xml';

declare updating function svs_lsvs:init_store($db) {
 (
  if (not(db:is-xml($db,$svs_lsvs:valuesets_doc))) then 
    db:add($db, $svs_lsvs:blank_valuesets,$svs_lsvs:valuesets_doc)
  else
    ()
  ,
  if ( not(  db:is-xml($db,$svs_lsvs:remote_value_sets))) then
    db:add($db, <valueSetLibrary/>,$svs_lsvs:remote_value_sets)
  else 
      ()
 )

};


declare updating function svs_lsvs:register_remote_value_set($db,$id,$url,$credentials) {
  let $vsl :=  db:open($db,$svs_lsvs:remote_value_sets)/valueSetLibrary
  (:bad bad plain text password:)
  let $reg_doc := <remoteValueSet id="{$id}" url="{$url}">{$credentials}</remoteValueSet>
  let $existing := $vsl/remoteValueSet[@id = @id]
  return
    if (not(exists($existing)))  then
      insert node $reg_doc into $vsl
    else 
      replace  node $existing with $reg_doc
};



declare  updating  function svs_lsvs:update_cache($db,$id)  
{


  let $results := svs_lsvs:retrieve_remote_value_set($db,$id)//svs:ValueSet
  return  
    if (exists($results)) 
    then  ( for $result in $results return svs_lsvs:insert($db,$result))
    else ( )
};

declare function svs_lsvs:get_remote_value_set_ids($db) {
  for $id in    db:open($db,$svs_lsvs:remote_value_sets)//remoteValueSet/@id
  return string($id)
};

declare function svs_lsvs:get_remote_value_set_url($db,$id) {
  text{ db:open($db,$svs_lsvs:remote_value_sets)//remoteValueSet[@id=$id]/@url}
};
declare function svs_lsvs:get_remote_value_set_credentials($db,$id) {
   db:open($db,$svs_lsvs:remote_value_sets)//remoteValueSet[@id=$id]/credentials
};

declare function svs_lsvs:retrieve_remote_value_set($db,$id) {
  let $url := svs_lsvs:get_remote_value_set_url($db,$id)
  let $credentials := svs_lsvs:get_remote_value_set_credentials($db,$id)
  let $request := 
    if ($credentials/@type = 'basic_auth' and $credentials/@username != '') 
      then 
      <http:request
      href='{$url}'  
      username='{$credentials/@username}'
      password='{$credentials/@password}'    
      send-authorization='true'
      method='get' />
    else
    <http:request
      href='{$url}'  
      send-authorization='false'
      method='get' />
  let $response :=  http:send-request($request)
  let $status := text{$response[1]/@status}
  return 
    if ($status = "200") 
    then $response[2]    
    else ()

};











declare function svs_lsvs:store_exists($db) {
  db:is-xml($db,$svs_lsvs:valuesets_doc)
};



declare function svs_lsvs:sample_sets() {
  for $file in file:list($svs_lsvs:base_path,true(),'*.xml')
  return file:resolve-path(concat($svs_lsvs:base_path,"/",$file))
};

declare function svs_lsvs:get_sample_value_set_list() {
<DescribedValueSets version="{$svs_lsvs:vers}">
  {  
  for $file in svs_lsvs:sample_sets()
  let $value_set_doc := doc($file)
  let $id :=text{$value_set_doc/svs:ValueSet/@id} (:ValueSet have @id while DesribedValueSet has @ID:)
  let $displayName :=text{$value_set_doc/svs:ValueSet/@displayName}
  let $version :=text{$value_set_doc/svs:ValueSet/@version}
  return 
    if ($id) 
      then 
      <svs:DescribedValueSet ID="{$id}" file="{$file}" displayName="{$displayName}" version="{$version}"/>
    else (<noID>{$file}</noID>)
  }
</DescribedValueSets>
};




declare function svs_lsvs:get_all_value_set_list($db) {
  let $vsets := db:open($db,$svs_lsvs:valuesets_doc)
  let $existing_ids := distinct-values($vsets//svs:DescribedValueSet/@ID)
  let $available_ids := $svs_lsvs:sample_value_set_list//svs:DescribedValueSet/@ID
  return <DescribedValueSets version="{$svs_lsvs:vers}">
  {
    (
      for $id in $existing_ids
      return if ($id = $available_ids) 
	then   $svs_lsvs:sample_value_set_list/svs:DescribedValueSet[@ID=$id]
      else  <svs:DescribedValueSet 
	ID="{$id}" 
	displayName="{$vsets//svs:DescribedValueSet[@ID = $id]/@displayName}" 
	version="{$vsets//svs:DescribedValueSet[@ID = $id]/@version}"/>
      ,
      for $id in $available_ids
      where not($id = $existing_ids)
      return    $svs_lsvs:sample_value_set_list/svs:DescribedValueSet[@ID=$id]
      )
  }
  </DescribedValueSets>  
};




declare function svs_lsvs:get_document_source($id) {
  text{$svs_lsvs:sample_value_set_list/svs:DescribedValueSet[@ID=$id]/@file}
};


declare function svs_lsvs:exists($db,$id) {
  svs_lsvs:store_exists($db) 
  and 
  exists(db:open($db,$svs_lsvs:valuesets_doc)//svs:DescribedValueSet[@ID = $id])
};




declare updating function svs_lsvs:load($db,$id) {
  let $doc_source := svs_lsvs:get_document_source($id)
  return if (not($doc_source)) 
    then  ()
  else
    let $svs_sets := db:open($db,$svs_lsvs:valuesets_doc)/DescribedValueSets
    let $svs := parse-xml(file:read-text($doc_source))	 
    for $value_set in $svs//svs:ValueSet
    return svs_lsvs:insert($db,$value_set)
};

declare updating function svs_lsvs:insert($db,$value_set) {
  let $vsets := db:open($db,$svs_lsvs:valuesets_doc)/DescribedValueSets
  let $id := string($value_set/@id)
  let $version := $value_set/@version
  let $existing :=  $vsets//svs:DescribedValueSet[@ID = $id and @version = $version]
  return
    if (functx:all-whitespace($id)) 
    then  ()
    else
      let $described_val_set := 
        <svs:DescribedValueSet ID="{$id}" displayName="{$value_set/@displayName}" >
	  {if ($version) then $version else ()}
          {$value_set/*}
	</svs:DescribedValueSet>
      return 
	if (exists($existing)) 
	then
	  (
	    for $node in $existing return  delete node $node,
	    insert node $described_val_set into $vsets
	  )
        else insert node $described_val_set into $vsets
};


declare updating function svs_lsvs:reload($db,$id) {
  svs_lsvs:load($db,$id) 
};





declare function svs_lsvs:get_multiple_described_value_sets($db,$filter) {
  let $dvs0 := db:open($db,$svs_lsvs:valuesets_doc)//svs:DescribedValueSet
  let $dvs1 := if (not($filter/@ID = '')) then $dvs0[@ID = $filter/@ID] else $dvs0
  let $dvs2 := if (not($filter/@DisplayNameContains = '')) then $dvs1[contains(@displayName,$filter/@DisplayNameContains)] else $dvs1
  let $dvs3 := if (not($filter/@SourceContains = '')) then $dvs2[contains(./svs:Source,$filter/@SourceContains)] else $dvs2
  let $dvs4 := if (not($filter/@PurposeContains = '')) then $dvs3[contains(./svs:Purpose,$filter/@PurposeContains)] else $dvs3
  let $dvs5 := if (not($filter/@DefinitionContains = '')) then $dvs4[contains(./svs:Definition,$filter/@DefinitionContains)] else $dvs4
  let $dvs6 := if (not($filter/@GroupContains = '')) then $dvs5[contains(./svs:Group,$filter/@GroupContains)] else $dvs5
  let $dvs7 := if (not($filter/@GroupOID = '')) then $dvs6[./svs:Group = $filter/@GroupOID] else $dvs6
  let $dvs8 := if (not($filter/@EffectiveDateBefore = '')) then $dvs7[./svs:EffectiveDate < @EffectiveDateBefore] else $dvs7
  let $dvs9 := if (not($filter/@EffectiveDateAfter = '')) then $dvs8[./svs:EffectiveDate > @EffectiveDateAfter] else $dvs8
  let $dvs10 := if (not($filter/@ExpirationDateBefore = '')) then $dvs9[./svs:ExpirationDate < @ExpirationDateBefore] else $dvs9
  let $dvs11 := if (not($filter/@ExpirationDateAfter = '')) then $dvs10[./svs:ExpirationDate > @ExpirationDateAfter] else $dvs10
  let $dvs12 := if (not($filter/@CreationDateBefore = '')) then $dvs11[./svs:CreationDate < @CreationDateBefore] else $dvs11
  let $dvs13 := if (not($filter/@CreationDateAfter = '')) then $dvs12[./svs:CreationDate > @CreationDateAfter] else $dvs12
  let $dvs14 := if (not($filter/@RevisionDateBefore = '')) then $dvs13[./svs:RevisionDate < @RevisionDateBefore] else $dvs13
  let $dvs15 := if (not($filter/@RevisionDateAfter = '')) then $dvs14[./svs:RevisionDate > @RevisionDateAfter] else $dvs14

  return  <svs:RetrieveMultipleValueSetsResponse >{$dvs15} </svs:RetrieveMultipleValueSetsResponse>

};


declare function svs_lsvs:get_single_version_value_set($db,$id) {
  svs_lsvs:get_single_version_value_set($db,$id,'')
};

declare function svs_lsvs:get_single_version_value_set($db,$id,$version) {
  svs_lsvs:get_single_version_value_set($db,$id,$version,'')
};

declare function svs_lsvs:get_single_version_value_set($db,$id, $version,$lang) {
  let $vs0 := db:open($db,$svs_lsvs:valuesets_doc)//svs:DescribedValueSet[@ID=$id]
  let $vers := if (functx:all-whitespace($version) )
     then  functx:max-string ($vs0[@version != '']/@version)  (:NEEDS TO CHANGE:)
     else  $version  
  let $vs1:= $vs0[@version = $vers]

  let $concept_lists := 
    if (functx:all-whitespace($lang) ) 
    then $vs1/svs:ConceptList
    else $vs1/svs:ConceptList[@xml:lang = $lang]
      
  return
  <svs:RetrieveValueSetResponse version="{$vers}" id="{$id}">
    {
      for $concept_list in $concept_lists
      let $val_set := $concept_list/..
      return
	(:ValueSet have @id while DesribedValueSet has @ID:)
	<svs:ValueSet id="{$val_set/@ID}" displayName="{$val_set/@displayName}" version="{$val_set/@version}">
	  {$concept_list}
	</svs:ValueSet>

    }
  </svs:RetrieveValueSetResponse>
};


declare function svs_lsvs:lookup_code($db,$code,$codeSystem) {
  svs_lsvs:lookup_code($db,$code,$codeSystem, false) 
};

declare function svs_lsvs:lookup_code($db,$code,$codeSystem, $lang) {
  let $vs0 := db:open($db,$svs_lsvs:valuesets_doc)//svs:DescribedValueSet

  let $concept_lists := 
    if ($lang)
      then 
      $vs0/svs:ConceptList[@xml:lang = $lang]
    else
      $vs0/svs:ConceptList

  let $concept :=  ($concept_lists/svs:Concept[@code = $code and @codeSystem = $codeSystem])[1]
  return string($concept/@displayName)
    
};


declare function svs_lsvs:get_single_version_code($db,$code,$id) {
  svs_lsvs:get_single_version_code($db,$code,$id, false())
};

declare function svs_lsvs:get_single_version_code($db,$code,$id, $version) {
  svs_lsvs:get_single_version_code($db,$code,$id, $version,false()) 
};

declare function svs_lsvs:get_single_version_code($db,$code,$id, $version,$lang) {
  let $vs0 := db:open($db,$svs_lsvs:valuesets_doc)//svs:DescribedValueSet[@ID=$id]
  let $vers := if (not($version = '')) then $version else max(xs:int($vs0/@version))
  let $vs1:= $vs0[@version = $vers]

  let $concept_lists := 
    if ($lang)
      then 
      $vs1/svs:ConceptList[@xml:lang = $lang]
    else
      $vs1/svs:ConceptList

  let $concepts :=  $concept_lists/svs:Concept[@code = $code]

  return <RetrieveValueSetCodeResponse> (:Not to SVS standard :)
  {
    for $concept in $concepts
    let $concept_list := $concept/..
    let $val_set := $concept_list/..
    return
      (:ValueSet have @id while DesribedValueSet has @ID:)
    <svs:ValueSet id="{$val_set/@ID}" displayName="{$val_set/@displayName}" version="{$val_set/@version}">
      <svs:ConceptList xml:lang="$concept_list/@xml:lang">
	{$concept}
      </svs:ConceptList>
    </svs:ValueSet>
  }
  </RetrieveValueSetCodeResponse>
};

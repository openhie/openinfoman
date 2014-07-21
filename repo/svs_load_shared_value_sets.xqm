(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/openhie/openinfoman
:
:)
module namespace svs_lsvs = "https://github.com/openhie/openinfoman/svs_lsvs";
import module namespace file = "http://expath.org/ns/file";
declare namespace svs = "urn:ihe:iti:svs:2008";

(:WARNING: ValueSet have @id while DesribedValueSet has @ID:)


declare variable $svs_lsvs:vers := "1.1";
declare variable $svs_lsvs:base_path := concat(file:current-dir() ,'../resources/shared_value_sets/');
declare variable $svs_lsvs:valuesets_doc := "DescribedSharedValueSets.xml";
declare variable $svs_lsvs:sample_value_set_list := svs_lsvs:get_sample_value_set_list();
declare variable $svs_lsvs:blank_valuesets :=  <DescribedValueSets version="{$svs_lsvs:vers}"/>;



declare updating function svs_lsvs:init_store($db) {
  if (not(db:is-xml($db,$svs_lsvs:valuesets_doc))) then 
    db:add($db, $svs_lsvs:blank_valuesets,$svs_lsvs:valuesets_doc)
  else
    ()
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
  let $existing_ids := $vsets//svs:DescribedValueSet/@ID
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
  if (not(svs_lsvs:exists($db,$id)))  then
    let $doc_source := svs_lsvs:get_document_source($id)
    return if (not($doc_source)) 
      then  ()
    else
      let $svs_sets := db:open($db,$svs_lsvs:valuesets_doc)/DescribedValueSets
      let $svs := parse-xml(file:read-text($doc_source))	 
      for $val_set in $svs//svs:ValueSet
      let $described_val_set := 
      <svs:DescribedValueSet ID="{$val_set/@id}" displayName="{$val_set/@displayName}" version="{$val_set/@version}">
	{$val_set/*}
      </svs:DescribedValueSet>
      return insert node $described_val_set into $svs_sets
  else 
    ()
};


declare updating function svs_lsvs:reload($db,$id) {
  let $vsets := db:open($db,$svs_lsvs:valuesets_doc)
  let $existing := $vsets//svs:DescribedValueSet[@ID = $id]
  return 
    if (exists($existing)) 
      then
        (delete node $existing,
	svs_lsvs:load($db,$id))
      else
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
  let $vers := if (not($version = '')) then $version else max(xs:int($vs0/@version))
  let $vs1:= $vs0[@version = $vers]

  let $concept_lists := 
    if (not($lang = '')) 
      then 
      $vs1/svs:ConceptList[@xml:lang = $lang]
    else
      $vs1/svs:ConceptList
      
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
  svs_lsvs:lookup_code($db,$code,$codeSystem, '') 
};

declare function svs_lsvs:lookup_code($db,$code,$codeSystem, $lang) {
  let $vs0 := db:open($db,$svs_lsvs:valuesets_doc)//svs:DescribedValueSet

  let $concept_lists := 
    if (not($lang = '')) 
      then 
      $vs0/svs:ConceptList[@xml:lang = $lang]
    else
      $vs0/svs:ConceptList

  let $concept :=  ($concept_lists/svs:Concept[@code = $code and @codeSystem = $codeSystem])[1]
  return string($concept/@displayName)
    
};


declare function svs_lsvs:get_single_version_code($db,$code,$id) {
  svs_lsvs:get_single_version_code($db,$code,$id, '')
};

declare function svs_lsvs:get_single_version_code($db,$code,$id, $version) {
  svs_lsvs:get_single_version_code($db,$code,$id, $version,'') 
};

declare function svs_lsvs:get_single_version_code($db,$code,$id, $version,$lang) {
  let $vs0 := db:open($db,$svs_lsvs:valuesets_doc)//svs:DescribedValueSet[@ID=$id]
  let $vers := if (not($version = '')) then $version else max(xs:int($vs0/@version))
  let $vs1:= $vs0[@version = $vers]

  let $concept_lists := 
    if (not($lang = '')) 
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

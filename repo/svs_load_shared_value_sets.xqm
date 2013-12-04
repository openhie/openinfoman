(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/his-interop/openinfoman
:
:)
module namespace svs_lsvs = "https://github.com/his-interop/openinfoman/svs_lsvs";

declare namespace svs = "urn:ihe:iti:svs:2008";
declare variable $svs_lsvs:vers := "1.0";
declare variable $svs_lsvs:base_path := '../resources/shared_value_sets/';
declare variable $svs_lsvs:valuesets_doc := "SharedValueSets.xml";
declare variable $svs_lsvs:sample_value_sets := svs_lsvs:get_sample_value_sets();
declare variable $svs_lsvs:blank_valuesets :=  <ValueSets version="{$svs_lsvs:vers}"/>;


declare function svs_lsvs:sample_sets() {
  for $file in file:list($svs_lsvs:base_path,true(),'*.xml')
  return file:resolve-path(concat($svs_lsvs:base_path,"/",$file))
};


declare function svs_lsvs:get_sample_value_sets() {
<ValueSets version="{$svs_lsvs:vers}">
  {  
  for $file in svs_lsvs:sample_sets()
  let $value_set_doc := doc($file)
  let $id :=text{$value_set_doc/svs:ValueSet/@id}
  let $displayName :=text{$value_set_doc/svs:ValueSet/@displayName}
  return if ($id) then (<svs:ValueSet id="{$id}" file="{$file}" displayName="{$displayName}"/>) 
else (<svs:ValueSet id="BLAH" file="{$file}" displayName="{$file}"/>)
  }
</ValueSets>
};

declare function svs_lsvs:get_value_set($db,$id) {
  svs_lsvs:get_all_sets($db)/svs:ValueSet[@id=$id]
};


declare function svs_lsvs:get_all_sets($db) {
  let $vsets := db:open($db,$svs_lsvs:valuesets_doc)
  let $existing_ids := $vsets/ValueSets/svs:ValueSet/@id
  let $available_ids := $svs_lsvs:sample_value_sets/svs:ValueSet/@id
  return <ValueSets version="{$svs_lsvs:vers}">
  {
    (
      for $id in $existing_ids
      return if ($id = $available_ids) 
	then   $svs_lsvs:sample_value_sets/svs:ValueSet[@id=$id]
      else  <svs:ValueSet id="{$id}" displayName="{$vsets/ValueSets/svs:ValueSet[@id = $id]/@displayName}"/>
      ,
    for $id in $available_ids
      where not($id = $existing_ids)
      return    $svs_lsvs:sample_value_sets/svs:ValueSet[@id=$id]
      )
  }
  </ValueSets>  
};



declare updating function svs_lsvs:init_store($db) {
  if (not(db:is-xml($db,$svs_lsvs:valuesets_doc))) then 
    db:add($db, $svs_lsvs:blank_valuesets,$svs_lsvs:valuesets_doc)
  else
    ()
};


declare function svs_lsvs:store_exists($db) {
  db:is-xml($db,$svs_lsvs:valuesets_doc)
};


declare function svs_lsvs:get_document_source($id) {
  text{$svs_lsvs:sample_value_sets/svs:ValueSet[@id=$id]/@file}
};


declare function svs_lsvs:exists($db,$id) {
  svs_lsvs:store_exists($db) 
  and 
  exists(db:open($db,$svs_lsvs:valuesets_doc)/ValueSets/svs:ValueSet[@id = $id])
};




declare updating function svs_lsvs:load($db,$id) {
  if (not(svs_lsvs:exists($db,$id)))  then
    let $doc_source := svs_lsvs:get_document_source($id)
    return if ($doc_source) then 
        let $svs_sets := db:open($db,$svs_lsvs:valuesets_doc)/ValueSets
	let $svs := parse-xml(file:read-text($doc_source))
	return insert node $svs into $svs_sets
      else
	()
  else 
    ()
};


declare updating function svs_lsvs:reload($db,$id) {
  let $existing := svs_lsvs:get($db,$id)
  return if (exists($existing)) then
    (delete node $existing,
    svs_lsvs:load($db,$id))
  else
    svs_lsvs:load($db,$id)
    
};

declare function svs_lsvs:get($db,$id) {
  if (svs_lsvs:store_exists($db) ) then
    db:open($db,$svs_lsvs:valuesets_doc)/ValueSets/svs:ValueSet[@id = $id]
  else
    ()
};


declare function svs_lsvs:get_code($db,$id,$code,$language) {
  let $lang :=   if ($language) then $language else "en-US"
  return db:open($db,$svs_lsvs:valuesets_doc)/ValueSets/svs:ValueSet[@id = $id]/svs:ConceptList[@xml:lang = $lang]/svs:Concept[@code = $code] 
};



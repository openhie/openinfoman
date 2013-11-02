(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/his-interop/openinfoman
:
:)
module namespace csd_lsc = "https://github.com/his-interop/openinfoman/csd_lsc";
import module namespace csd_psd = "https://github.com/his-interop/openinfoman/csd_psd" at "csd_poll_service_directories.xqm";

declare namespace csd = "urn:ihe:iti:csd:2013";
declare default element  namespace   "urn:ihe:iti:csd:2013";


declare function csd_lsc:get_document_name($name) {
  concat("local_services_cache/",$name,".xml")
};

declare function csd_lsc:directory_exists($collection,$name) {
  db:is-xml(db:name($collection),csd_lsc:get_document_name($name))
};

declare updating function csd_lsc:create_cache($collection,$name) {  
db:add( db:name($collection),  csd_lsc:blank_directory()  , csd_lsc:get_document_name($name)  )
};


declare function csd_lsc:blank_directory()
{
<CSD xmlns:csd="urn:ihe:iti:csd:2013" xmlns="urn:ihe:iti:csd:2013">
  <organizationDirectory/>
  <serviceDirectory/>
  <facilityDirectory/>
  <providerDirectory/>
</CSD>
};

declare updating function csd_lsc:empty_cache($collection,$name) 
{
  if (csd_lsc:directory_exists($collection,$name)) 
    then   
    (db:delete(db:name($collection),csd_lsc:get_document_name($name)) ,
    csd_lsc:create_cache($collection,$name))
  else     
    csd_lsc:create_cache($collection,$name)
    
};

declare function csd_lsc:get_cache($collection,$name) 
{
 if (csd_lsc:directory_exists($collection,$name)) then
    db:open(db:name($collection),csd_lsc:get_document_name($name)) 
  else csd_lsc:blank_directory()
};


declare variable $csd_lsc:beginning_of_time := '2013-10-01T00:00:00+00:00';
declare variable $csd_lsc:cache_meta_doc := 'local_cache_meta.xml';



declare function csd_lsc:get_cache_data($collection,$name) 
{
  if ( not( db:is-xml(db:name($collection),$csd_lsc:cache_meta_doc)))  then
    if ($name) then
      ()
    else
      <cacheData/>
  else
    let $meta_doc :=  db:open(db:name($collection),$csd_lsc:cache_meta_doc)
    return if ($name) then
      $meta_doc/cacheData/serviceCache[@name = $name]
    else
      $meta_doc/cacheData
};


declare updating function csd_lsc:drop_cache_data($collection,$name) 
{
  if ( not(db:is-xml(db:name($collection),$csd_lsc:cache_meta_doc)))  then
    ()
  else
    let $meta_doc :=  db:open(db:name($collection),$csd_lsc:cache_meta_doc)
      return if ($name) then
	delete node $meta_doc/cacheData/serviceCache[@name = $name]
      else
	delete node $meta_doc/cacheData/*

};

declare updating function csd_lsc:init_cache_meta($collection) {
  if ( not(db:is-xml(db:name($collection),$csd_lsc:cache_meta_doc)))  then
    db:add(db:name($collection), <cacheData/>,$csd_lsc:cache_meta_doc)
    else 
      ()
};

declare updating function csd_lsc:set_service_directory_mtime($collection,$name,$mtime) 
{
  ( csd_lsc:init_cache_meta($collection)
  ,
  let $meta :=  db:open(db:name($collection),$csd_lsc:cache_meta_doc)/cacheData      
  return
    if (not(exists($meta/serviceCache[@name = $name])))  then
      insert node <serviceCache name="{$name}" mtime="{$csd_lsc:beginning_of_time}"/> into $meta
    else 
      replace value of node$meta/serviceCache[@name = $name]/@mtime with $mtime
  )
      

  
};

declare function csd_lsc:get_service_directory_mtime($collection,$name) 
{
  if ( db:is-xml(db:name($collection),$csd_lsc:cache_meta_doc))  then
    let $mtime := text{db:open(db:name($collection),$csd_lsc:cache_meta_doc)/cacheData/serviceCache[@name = $name]/@mtime}
    return if ($mtime) then
	$mtime
      else 
	$csd_lsc:beginning_of_time
    else
      $csd_lsc:beginning_of_time
      
};


declare updating function csd_lsc:update_cache($collection,$name) 
{
  (
    if (not(csd_lsc:directory_exists($collection,$name)))
      then csd_lsc:create_cache($collection,$name) else ()
  ,
  let $mtime :=  csd_lsc:get_service_directory_mtime($collection,$name)
(:  let $result2 := csd_psd:poll_service_directory($name,$mtime)  :)
  let $result := () 
  let $cache_doc := csd_lsc:get_cache($collection,$name) 
  let $mtime := current-dateTime()
  return (
    csd_lsc:set_service_directory_mtime($collection,$name,$mtime),
    csd_lsc:refresh_doc($cache_doc,$result)
  )
  )

};


declare updating function csd_lsc:refresh_doc($cache_doc,$updates) 
{
  let $providerDir := $cache_doc/CSD/providerDirectory
  for $new in  $updates/providerDirectory/*
  let $old := $providerDir/provider[@oid = $new/@oid]
  return if ($old) then
    replace  node $old with $new
  else
    insert node $new into $providerDir
};
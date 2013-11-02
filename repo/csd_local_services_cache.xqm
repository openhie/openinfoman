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
  "local_services_cache/{$name}.xml"
};

declare function csd_lsc:directory_exists($collection,$name) {
  db:is-xml($collection,csd_lsc:get_document_name($name))
};

declare updating function csd_lsc:create_cache($collection,$name) {  
  db:create(
    $collection,
    <CSD>
      <organizationDirectory/>
      <serviceDirectory/>
      <facilityDirectory/>
      <providerDirectory/>
    </CSD>
    ,
    csd_lsc:get_document_name($name)
    )
};
  
declare updating function csd_lsc:empty_cache($collection,$name) 
{
  if (csd_lsc:directory_exists($collection,$name)) 
    then   
    (db:delete($collection,csd_lsc:get_document_name($name)) ,
    csd_lsc:create_cache($collection,$name))
  else     
    csd_lsc:create_cache($collection,$name)
    
};

declare function csd_lsc:get_cache($collection,$name) 
{
   if (csd_lsc:directory_exists($collection,$name)) then db:open($collection,csd_lsc:get_document_name($name)) else ()
};


declare variable $csd_lsc:beginning_of_time := '2013-10-01T00:00:00+00:00';
declare variable $csd_lsc:cache_meta_doc := 'local_cache_meta.xml';



declare function csd_lsc:get_cache_data($collection,$name) 
{
  if ( not( db:is-xml($collection,$csd_lsc:cache_meta_doc)))  then
    ()
  else
    let $meta_doc :=  db:open($collection,$csd_lsc:cache_meta_doc)
    return if ($name) then
      $meta_doc/cacheData/serviceCache[@name = $name]
    else
      $meta_doc/cacheData
};


declare updating function csd_lsc:drop_cache_data($collection,$name) 
{
  if ( not(db:is-xml($collection,$csd_lsc:cache_meta_doc)))  then
    ()
  else
    let $meta_doc :=  db:open($collection,$csd_lsc:cache_meta_doc)
      return if ($name) then
	delete node $meta_doc/cacheData/serviceCache[@name = $name]
      else
	delete node $meta_doc/cacheData/*

};

declare updating function csd_lsc:set_service_directory_mtime($collection,$name,$mtime) 
{
  (if ( not(db:is-xml($collection,$csd_lsc:cache_meta_doc)))  then
    db:create($collection, <cacheData/>,$csd_lsc:cache_meta_doc)
  else (),
    
    let $meta_doc :=  db:open($collection,$csd_lsc:cache_meta_doc)
      
    return
      (if (not($meta_doc/cacheData/serviceCache[@name = $name]))  then
	insert node <serviceCache name="{$name}" mtime="{$csd_lsc:beginning_of_time}"/> into $meta_doc/cacheData
      else (),
      replace node $meta_doc/cacheData/serviceCache[@name = $name]/@mtime with $mtime)
      

  )
};

declare function csd_lsc:get_service_directory_mtime($collection,$name) 
{
  if ( db:is-xml($collection,$csd_lsc:cache_meta_doc))  then
    let $mtime := text{db:open($collection,$csd_lsc:cache_meta_doc)/cacheData/serviceCache[@name = $name]/@mtime}
    return if ($mtime) then
	$mtime
      else ()
    else
      $csd_lsc:beginning_of_time
      
};


declare updating function csd_lsc:update_cache($collection,$name) 
{
  let $mtime :=  csd_lsc:get_service_directory_mtime($collection,$name)
  let $result := csd_psd:poll_service_directory($name,())
  return if ($result) then
    ( if (not(csd_lsc:directory_exists($collection,$name)))
      then csd_lsc:create_cache($collection,$name)
    else ()
      ,
      let $cache_doc := csd_lsc:get_cache($collection,$name) 
      let $mtime := current-dateTime()
	
      return csd_lsc:set_service_directory_mtime($collection,$name,$mtime)
		      
		      )
  else
    ()

    

    (:DO SOMETHING:)

};


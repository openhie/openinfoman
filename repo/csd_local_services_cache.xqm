(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/his-interop/openinfoman
:
:)
module namespace csd_lsc = "https://github.com/his-interop/openinfoman/csd_lsc";
import module namespace csd_psd = "https://github.com/his-interop/openinfoman/csd_psd";

declare namespace csd = "urn:ihe:iti:csd:2013";
declare default element  namespace   "urn:ihe:iti:csd:2013";


declare function csd_lsc:get_document_name($name) {
  concat("local_services_cache/",$name,".xml")
};

declare function csd_lsc:directory_exists($db,$name) {
  db:is-xml($db,csd_lsc:get_document_name($name))
};

declare updating function csd_lsc:create_cache($db,$name) {  
db:add( $db,  csd_lsc:blank_directory()  , csd_lsc:get_document_name($name)  )
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

declare updating function csd_lsc:empty_cache($db,$name) 
{
  (if (csd_lsc:directory_exists($db,$name)) 
    then   
    (db:delete($db,csd_lsc:get_document_name($name)) ,
    csd_lsc:create_cache($db,$name))
  else     
    csd_lsc:create_cache($db,$name)
    ,
    csd_lsc:set_service_directory_mtime($db,$name,$csd_lsc:beginning_of_time) 
    )
    
};

declare function csd_lsc:get_cache($db,$name) 
{
 if (csd_lsc:directory_exists($db,$name)) then
    db:open($db,csd_lsc:get_document_name($name)) 
  else csd_lsc:blank_directory()
};


declare variable $csd_lsc:beginning_of_time := '2013-10-01T00:00:00+00:00';
declare variable $csd_lsc:cache_meta_doc := 'local_cache_meta.xml';



declare function csd_lsc:get_cache_data($db,$name) 
{
  if ( not( db:is-xml($db,$csd_lsc:cache_meta_doc)))  then
    if ($name) then
      ()
    else
      <cacheData/>
  else
    let $meta_doc :=  db:open($db,$csd_lsc:cache_meta_doc)
    return if ($name) then
      $meta_doc/cacheData/serviceCache[@name = $name]
    else
      $meta_doc/cacheData
};


declare updating function csd_lsc:drop_cache_data($db,$name) 
{
  if ( not(db:is-xml($db,$csd_lsc:cache_meta_doc)))  then
    ()
  else
    let $meta_doc :=  db:open($db,$csd_lsc:cache_meta_doc)
      return if ($name) then
	delete node $meta_doc/cacheData/serviceCache[@name = $name]
      else
	delete node $meta_doc/cacheData/*

};

declare  function csd_lsc:cache_meta_exists($db) {
  db:is-xml($db,$csd_lsc:cache_meta_doc)
};


declare updating function csd_lsc:init_cache_meta($db) {
  if ( not(csd_lsc:cache_meta_exists($db)))  then
    db:add($db, <cacheData/>,$csd_lsc:cache_meta_doc)
  else 
      ()
};

declare updating function csd_lsc:set_service_directory_mtime($db,$name,$mtime) 
{
  ( csd_lsc:init_cache_meta($db)
  ,
  let $meta :=  db:open($db,$csd_lsc:cache_meta_doc)/cacheData      
  return
    if (not(exists($meta/serviceCache[@name = $name])))  then
      insert node <serviceCache name="{$name}" mtime="{$csd_lsc:beginning_of_time}"/> into $meta
    else if (not(exists($meta/serviceCache[@name = $name]/@mtime))) then
      let $attr := attribute {"mtime"}{ $csd_lsc:beginning_of_time}
      return ( insert  node $attr into $meta/serviceCache[@name = $name])
    else
      replace value of node $meta/serviceCache[@name = $name]/@mtime with $mtime
  )
      

  
};

declare function csd_lsc:get_service_directory_mtime($db,$name) 
{
  if ( db:is-xml($db,$csd_lsc:cache_meta_doc))  then
    let $mtime := text{db:open($db,$csd_lsc:cache_meta_doc)/cacheData/serviceCache[@name = $name]/@mtime}
    return if ($mtime) then
	$mtime
      else 
	$csd_lsc:beginning_of_time
    else
      $csd_lsc:beginning_of_time
      
};



declare  updating  function csd_lsc:update_cache($db,$name)  
{

  let $mtime :=  csd_lsc:get_service_directory_mtime($db,$name)
(:  querying against self during an update will cause a deadlock :)
(:  see or :)
(:  http://www.mail-archive.com/basex-talk@mailman.uni-konstanz.de/msg02999.htmlhttp://www.mail-archive.com/basex-talk@mailman.uni-konstanz.de/msg02999.html  :)
(:  possible work-around: http://docs.basex.org/wiki/Server_Protocol ? :)
  let $result := csd_psd:poll_service_directory($db,$name,$mtime)    
  let $cache_doc := csd_lsc:get_cache($db,$name) 

  let $currtime := current-dateTime()
  return (
    csd_lsc:refresh_doc($cache_doc,$result)   
    ,csd_lsc:set_service_directory_mtime($db,$name,$currtime) 
      
  )


};


declare updating function csd_lsc:refresh_doc($cache_doc,$updates) 
{
  (
   csd_lsc:update_directory($cache_doc/csd:CSD/csd:organizationDirectory,$updates/csd:CSD/csd:organizationDirectory)
  ,csd_lsc:update_directory($cache_doc/csd:CSD/csd:facilityDirectory,$updates/csd:CSD/csd:facilityDirectory)
  ,csd_lsc:update_directory($cache_doc/csd:CSD/csd:serviceDirectory,$updates/csd:CSD/csd:serviceDirectory)
  ,csd_lsc:update_directory($cache_doc/csd:CSD/csd:providerDirectory,$updates/csd:CSD/csd:providerDirectory)
  )
};

declare updating function csd_lsc:update_directory($oldDir,$newDir) 
{
  for $new in  $newDir/*
  let $old := $oldDir/*[@oid = $new/@oid]
  return if ($old) then
    replace node $old with $new
  else
    insert node $new into $oldDir
};
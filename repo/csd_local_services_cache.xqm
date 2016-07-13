(:~
: This is the Care Services Discovery stored query registry
: @version 1.0
: @see https://github.com/openhie/openinfoman
:
:)
module namespace csd_lsc = "https://github.com/openhie/openinfoman/csd_lsc";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace csd_psd = "https://github.com/openhie/openinfoman/csd_psd";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
declare namespace csd = "urn:ihe:iti:csd:2013";
declare default element  namespace   "urn:ihe:iti:csd:2013";


declare function csd_lsc:get_document_name($name) {
  csd_dm:document_source($name) 
(:  concat("local_services_cache/",$name,".xml") :)
};

declare function csd_lsc:directory_exists($name) {
  db:is-xml($csd_webconf:db,csd_lsc:get_document_name($name))
};



declare updating function csd_lsc:empty_cache($name) 
{
  (
    csd_dm:empty($name)
    ,csd_lsc:set_service_directory_mtime($name,$csd_lsc:beginning_of_time)
   )
    
};

declare function csd_lsc:get_cache($name) 
{
 if (csd_lsc:directory_exists($name)) then
    db:open($csd_webconf:db,csd_lsc:get_document_name($name)) 
  else csd_dm:blank_directory()
};


declare variable $csd_lsc:beginning_of_time := '1970-01-01T00:00:00+00:00';
declare variable $csd_lsc:cache_meta_doc := 'local_cache_meta.xml';



declare function csd_lsc:get_cache_data($name) 
{
  if ( not( db:is-xml($csd_webconf:db,$csd_lsc:cache_meta_doc)))  then
    if ($name) then
      ()
    else
      <cacheData/>
  else
    let $meta_doc :=  db:open($csd_webconf:db,$csd_lsc:cache_meta_doc)
    return if ($name) then
      $meta_doc/cacheData/serviceCache[@name = $name]
    else
      $meta_doc/cacheData
};


declare updating function csd_lsc:drop_cache_data($name) 
{
  if ( not(db:is-xml($csd_webconf:db,$csd_lsc:cache_meta_doc)))  then
    ()
  else
    let $meta_doc :=  db:open($csd_webconf:db,$csd_lsc:cache_meta_doc)
      return if ($name) then
	delete node $meta_doc/cacheData/serviceCache[@name = $name]
      else
	delete node $meta_doc/cacheData/*

};

declare  function csd_lsc:cache_meta_exists() {
  db:is-xml($csd_webconf:db,$csd_lsc:cache_meta_doc)
};


declare updating function csd_lsc:init_cache_meta() {
  if ( not(csd_lsc:cache_meta_exists()))  then
    db:add($csd_webconf:db, <cacheData/>,$csd_lsc:cache_meta_doc)
  else 
      ()
};

declare updating function csd_lsc:set_service_directory_mtime($name,$mtime) 
{
  ( csd_lsc:init_cache_meta()
  ,
  try {
    let $dt :=  xs:dateTime($mtime) (: just to make sure it's valid :)
    let $meta :=  db:open($csd_webconf:db,$csd_lsc:cache_meta_doc)/cacheData      
    return
      if (not(exists($meta/serviceCache[@name = $name])))  
      then insert node <serviceCache name="{$name}" mtime="{$csd_lsc:beginning_of_time}"/> into $meta
      else if (not(exists($meta/serviceCache[@name = $name]/@mtime))) 
      then
        let $attr := attribute {"mtime"}{ $csd_lsc:beginning_of_time}
        return ( insert  node $attr into $meta/serviceCache[@name = $name])
      else
        replace value of node $meta/serviceCache[@name = $name]/@mtime with $mtime
  } catch * {
    let $t := trace($mtime,"Invalid date time sent")
    return ()  (: do nothing :)
  }
  )
      

  
};

declare function csd_lsc:get_service_directory_mtime($name) 
{
  if ( db:is-xml($csd_webconf:db,$csd_lsc:cache_meta_doc))  then
    let $mtime := text{db:open($csd_webconf:db,$csd_lsc:cache_meta_doc)/cacheData/serviceCache[@name = $name]/@mtime}
    return if ($mtime) then
	$mtime
      else 
	$csd_lsc:beginning_of_time
    else
      $csd_lsc:beginning_of_time
      
};



declare  updating  function csd_lsc:update_cache($name)  
{

  let $mtime :=  csd_lsc:get_service_directory_mtime($name)
(:  querying against self during an update will cause a deadlock :)
(:  see or :)
(:  http://www.mail-archive.com/basex-talk@mailman.uni-konstanz.de/msg02999.htmlhttp://www.mail-archive.com/basex-talk@mailman.uni-konstanz.de/msg02999.html  :)
(:  possible work-around: http://docs.basex.org/wiki/Server_Protocol ? :)
  let $currtime := current-dateTime()
  let $result := csd_psd:poll_service_directory($name,$mtime)    
  let $cache_doc := csd_lsc:get_cache($name) 


  return (
    csd_lsc:refresh_doc($cache_doc,$result)   
    ,csd_lsc:set_service_directory_mtime($name,$currtime) 
      
  )


};


declare updating function csd_lsc:refresh_doc($cache_doc,$updates)
{
  csd_lsc:refresh_doc($cache_doc,$updates,true()) 
};

declare updating function csd_lsc:refresh_doc($cache_doc,$updates,$overwriteExisting) 
{
  (
   csd_lsc:update_directory($cache_doc/csd:CSD/csd:organizationDirectory,$updates/(csd:CSD/csd:organizationDirectory|csd:organizationDirectory),$overwriteExisting)
  ,csd_lsc:update_directory($cache_doc/csd:CSD/csd:facilityDirectory,$updates/(csd:CSD/csd:facilityDirectory|csd:facilityDirectory),$overwriteExisting)
  ,csd_lsc:update_directory($cache_doc/csd:CSD/csd:serviceDirectory,$updates/(csd:CSD/csd:serviceDirectory|csd:serviceDirectory),$overwriteExisting)
  ,csd_lsc:update_directory($cache_doc/csd:CSD/csd:providerDirectory,$updates/(csd:CSD/csd:providerDirectory|csd:providerDirectory),$overwriteExisting)
  )
};



declare updating function csd_lsc:update_directory($oldDir,$newDir)  {
  csd_lsc:update_directory($oldDir,$newDir,true()) 
};

declare updating function csd_lsc:update_directory($oldDir,$newDir,$overwriteExisting) 
{
  for $new in  $newDir/*
  let $old := $oldDir/*[@entityID = $new/@entityID] (:there may be more than one:)    
  return (  
     if ($overwriteExisting) 
     then
       (
	 for $o in $old
	 return delete node $o     
	 ,
	 insert node $new into $oldDir 
       )
     else 
       (
	 if (count($old) > 0)
	 then ()
	 else insert node $new into $oldDir 
       )
   )
};
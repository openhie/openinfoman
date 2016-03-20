module namespace page = 'http://basex.org/modules/web-page';

import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace csd_webui =  "https://github.com/openhie/openinfoman/csd_webui";
import module namespace csr_proc = "https://github.com/openhie/openinfoman/csr_proc";
declare   namespace   csd = "urn:ihe:iti:csd:2013";



declare updating
  %rest:path("/CSD/duplicates/{$doc_name}/mark/{$entityID}")
  %rest:GET
  %rest:query-param("masterID", "{$masterID}")
  %output:method("xhtml")
  function page:mark_duplicate_get($doc_name,$entityID,$masterID)
{
  (
    let $doc := csd_dm:open_document($doc_name)
    let $requestParams :=
      <csd:requestParams function="urn:openhie.org:openinfoman:mark_duplicate"  resource="{$doc_name}" base_url="{csd_webui:generateURL()}">
	<masterEntity entityID="{$masterID}"/>
	<duplicateEntity entityID="{$entityID}"/>
      </csd:requestParams>
    
    return csr_proc:process_updating_CSR_stored_results( $doc,$requestParams)
    ,
    csd_webui:redirect_out(("/CSD/duplicates/", $doc_name , "/manage/" ,  $entityID ))
  )

};

declare updating
  %rest:path("/CSD/duplicates/{$doc_name}/markPotential/{$entityID}")
  %rest:GET
  %rest:query-param("masterID", "{$masterID}")
  %output:method("xhtml")
  function page:mark_pot_duplicate_get($doc_name,$entityID,$masterID)
{
  (
    let $doc := csd_dm:open_document($doc_name)
    let $requestParams :=
      <csd:requestParams function="urn:openhie.org:openinfoman:mark_potential_duplicate"  resource="{$doc_name}" base_url="{csd_webui:generateURL()}">
	<masterEntity entityID="{$masterID}"/>
	<duplicateEntity entityID="{$entityID}"/>
      </csd:requestParams>
    
    return csr_proc:process_updating_CSR_stored_results( $doc,$requestParams)
    ,
    csd_webui:redirect_out(("/CSD/duplicates/", $doc_name , "/manage/" ,  $entityID ))
  )

};


declare updating
  %rest:path("/CSD/duplicates/{$doc_name}/mark/{$entityID}/{$masterID}")
  %rest:GET
  %output:method("xhtml")
  function page:mark_duplicate($doc_name,$entityID,$masterID)
{
  (
    let $doc := csd_dm:open_document($doc_name)
    let $requestParams :=
      <csd:requestParams function="urn:openhie.org:openinfoman:mark_duplicate"  resource="{$doc_name}" base_url="{csd_webui:generateURL()}">
	<masterEntity entityID="{$masterID}"/>
	<duplicateEntity entityID="{$entityID}"/>
      </csd:requestParams>
    
    return csr_proc:process_updating_CSR_stored_results( $doc,$requestParams)
    ,
    csd_webui:redirect_out(("/CSD/duplicates/", $doc_name , "/manage/" ,  $entityID ))
  )

};


declare updating
  %rest:path("/CSD/duplicates/{$doc_name}/markPotential/{$entityID}/{$masterID}")
  %rest:GET
  %output:method("xhtml")
  function page:mark_potential_duplicate($doc_name,$entityID,$masterID)
{
  (
    let $doc := csd_dm:open_document($doc_name)
    let $requestParams :=
      <csd:requestParams function="urn:openhie.org:openinfoman:mark_potential_duplicate"  resource="{$doc_name}" base_url="{csd_webui:generateURL()}">
	<masterEntity entityID="{$masterID}"/>
	<duplicateEntity entityID="{$entityID}"/>
      </csd:requestParams>

    return csr_proc:process_updating_CSR_stored_results( $doc,$requestParams)
    ,
    csd_webui:redirect_out(("/CSD/duplicates/", $doc_name , "/manage/" ,$entityID ))
  )

};



declare updating
  %rest:path("/CSD/duplicates/{$doc_name}/remove/{$entityID}/{$masterID}")
  %rest:GET
  %output:method("xhtml")
  function page:remove_duplicate($doc_name,$entityID,$masterID)
{
  (
    let $doc := csd_dm:open_document($doc_name)
    let $requestParams :=
      <csd:requestParams function="urn:openhie.org:openinfoman:delete_duplicate"  resource="{$doc_name}" base_url="{csd_webui:generateURL()}">
	<masterEntity entityID="{$masterID}"/>
	<duplicateEntity entityID="{$entityID}"/>
      </csd:requestParams>

    return csr_proc:process_updating_CSR_stored_results( $doc,$requestParams)
    ,
    csd_webui:redirect_out(("/CSD/duplicates/", $doc_name, "/manage/" , $entityID ))
  )

};


declare updating
  %rest:path("/CSD/duplicates/{$doc_name}/removePotential/{$entityID}/{$masterID}")
  %rest:GET
  %output:method("xhtml")
  function page:remove_potential_duplicate($doc_name,$entityID,$masterID)
{
  (
    let $doc := csd_dm:open_document($doc_name)
    let $requestParams :=
      <csd:requestParams function="urn:openhie.org:openinfoman:delete_potential_duplicate"  resource="{$doc_name}" base_url="{csd_webui:generateURL()}">
	<masterEntity entityID="{$masterID}"/>
	<duplicateEntity entityID="{$entityID}"/>
      </csd:requestParams>

    return csr_proc:process_updating_CSR_stored_results( $doc,$requestParams)
    ,
    csd_webui:redirect_out(("/CSD/duplicates/", $doc_name, "/manage/"  , $entityID ))
  )

};


declare
  %rest:path("/CSD/duplicates/{$doc_name}/manage/{$entityID}")
  %rest:GET
  %output:method("xhtml")
  function page:manage($doc_name,$entityID)
{ 
  let $doc := csd_dm:open_document($doc_name)
  let $entityObj :=  ($doc/csd:CSD/*/*[@entityID = $entityID])[1]
  let $entity := local-name($entityObj)
  let $entities:=
    switch($entity)
    case "provider" return $doc/csd:CSD/csd:providerDirectory/csd:provider
    case "facility" return $doc/csd:CSD/csd:facilityDirectory/csd:facility
    case "organization" return $doc/csd:CSD/csd:organizationDirectory/csd:organization
    case "service" return $doc/csd:CSD/csd:serviceDirectory/csd:service
    default return ()


  let $url := csd_webui:generateURL(("CSD/directory", $doc_name, "get", $entity , $entityID))
  let $name :=
	  if (local-name($entityObj) = 'provider')
	  then (($entityObj/csd:demographic/csd:name/csd:commonName)[1])/text()
   	  else $entityObj/csd:primaryName/text()
    
  let $dlist :=
    <ul>
      {
	for $dup in $entities[csd:otherID[@assigningAuthorityName='urn:openhie.org:openinfoman' and @code='duplicate' and text() = $entityID]]
	let $did := string($dup/@entityID)
	let $dname :=
	  if (local-name($entityObj) = 'provider')
	  then (($dup/csd:demographic/csd:name/csd:commonName)[1])/text()
   	  else $dup/csd:primaryName/text()
	let $durl := csd_webui:generateURL(("CSD/directory/", $doc_name, "get", $entity , $did))
	return
	  <li>Record duplicated by <a href="{$durl}">{$dname} [{$did}]</a></li>
      }
    </ul>

  let $elist :=
    <ul>
      {
	for $edup_id in $entityObj/csd:otherID[@assigningAuthorityName='urn:openhie.org:openinfoman' and @code='duplicate']
	let $eid := $edup_id/text()
	let $e := $entities[@entityID = $eid]
	let $ename :=
	  if (local-name($e) = 'provider')
	  then (($e/csd:demographic/csd:name/csd:commonName)[1])/text()
	  else $e/csd:primaryName/text()
	let $eurl := csd_webui:generateURL(("/CSD/directory/", $doc_name, "get", $entity ,  $eid))
	return
	  <li>Duplicates record <a href="{$eurl}"> {$ename} [{$eid}]</a></li>
      }
    </ul>

	  
    
  let $plist :=
    <ul>
      {
	for $pdup_id in $entityObj/csd:otherID[@assigningAuthorityName='urn:openhie.org:openinfoman' and @code='potential-duplicate']
	let $pid := $pdup_id/text()
	let $e := $entities[@entityID = $pid]
	let $ename :=
	  if (local-name($e) = 'provider')
	  then (($e/csd:demographic/csd:name/csd:commonName)[1])/text()
	  else $e/csd:primaryName/text()
	let $purl := csd_webui:generateURL(("CSD/directory", $doc_name, "get", $entity ,  $pid)		  )
	let $rurl := csd_webui:generateURL(( "CSD/duplicates", $doc_name ,"removePotential" ,  $entityID , $pid))
	let $murl := csd_webui:generateURL(( "CSD/duplicates", $doc_name ,"mark" ,  $entityID , $pid))
	return
	  <li>
	    Potential duplicate with <a href="{$purl}">{$ename} [{$pid}]</a>
	    <ul>
	      <li><a href="{$rurl}">Remove potential duplicate</a></li>
	      <li><a href="{$murl}">Mark as duplicate</a></li>
	    </ul>
	  </li>
      }
    </ul>

  let $content :=
  <div>
      Record for <a href="{$url}">{$name} [{$entityID}]</a>
      <h2>Records which duplicate this record</h2>
      {$dlist}
      <h2>Records which this record duplicates</h2>
      {$elist}
      <h2>Manage potential duplicate information for this record</h2>
      {$plist}
      <h2>Mark this record as a duplicate</h2>
      <form  action="{csd_webui:generateURL(('/CSD/duplicates',$doc_name,'mark',$entityID))}">
        CSD Entity ID of Master Record:
	<input name='masterID'/>
	<input type='submit' value='Mark Duplicate'/>
      </form>
      <h2>Mark this record as a potential duplicate</h2>
      <form  action="{csd_webui:generateURL(('/CSD/duplicates',$doc_name,'/markPotential',$entityID))}">
        CSD Entity ID of Master Record:
	<input name='masterID'/>
	<input type='submit' value='Mark Duplicate'/>
      </form>

      <hr/>
      <p>
	<a href="{csd_webui:generateURL(('CSD/duplicates',$doc_name,'list',$entity))}">List {$entity}  information for {$doc_name}</a>
      </p>
      <p>
	<a href="{csd_webui:generateURL(('CSD/duplicates',$doc_name,'list-dup',$entity))}">List {$entity} duplicate information for {$doc_name}</a>
      </p>
      <p>
	<a href="{csd_webui:generateURL(('CSD/duplicates',$doc_name,'list-pot-dup',$entity))}">List {$entity}  potential duplicate information for {$doc_name}</a>
      </p>
    </div>
  return csd_webui:wrapper($content)      
};


declare
  %rest:path("/CSD/duplicates/{$doc_name}/list/{$entity}")
  %rest:GET
  %output:method("xhtml")
  %rest:query-param("page", "{$page}", 0)
  function page:list($doc_name,$entity,$page) 
{ 
  let $doc := csd_dm:open_document($doc_name)
  let $entities:=
    switch($entity)
    case "provider" return $doc/csd:CSD/csd:providerDirectory/csd:provider
    case "facility" return $doc/csd:CSD/csd:facilityDirectory/csd:facility
    case "organization" return $doc/csd:CSD/csd:organizationDirectory/csd:organization
    case "service" return $doc/csd:CSD/csd:serviceDirectory/csd:service
    default return ()

  let $first := $page * 50 + 1
  let $last := ($page +1) * 50 
  let $p_entities := $entities[position() >= $first and position() <= $last]

  let $list :=
    <ul>
      {
	for $e in $p_entities
	let $url := csd_webui:generateURL(( "/CSD/duplicates", $doc_name ,"manage" , string($e/@entityID)))
	let $ename :=
	  if (local-name($e) = 'provider')
	  then (($e/csd:demographic/csd:name/csd:commonName)[1])/text()
	  else $e/csd:primaryName/text()
	return <li>Manage <a href="{$url}">{$ename} [{string($e/@entityID)}]</a></li>
      }
    </ul>
  let $next := csd_webui:generateURL(( "CSD/duplicates", $doc_name ,"list" , concat( $entity , "?page=" , ($page +1))))
  let $prev := csd_webui:generateURL(( "CSD/duplicates", $doc_name ,"list" , concat($entity , "?page=" , ($page -1))))
  let $content :=
    <div>
      <h2>Records </h2>
      {$list}
      <hr/>
      { if (($page) >= 1 ) then   <a href="{$prev}">Previous Page</a> else () }
      <a href="{$next}">Next Page</a>	    
    </div>

  return csd_webui:wrapper($content)
};




declare
  %rest:path("/CSD/duplicates/{$doc_name}/list-dup/{$entity}")
  %rest:GET
  %output:method("xhtml")
  %rest:query-param("page", "{$page}", 0)
  function page:duplicate_list($doc_name,$entity,$page) 
{ 
  let $doc := csd_dm:open_document($doc_name)
  let $entities:=
    switch($entity)
    case "provider" return $doc/csd:CSD/csd:providerDirectory/csd:provider
    case "facility" return $doc/csd:CSD/csd:facilityDirectory/csd:facility
    case "organization" return $doc/csd:CSD/csd:organizationDirectory/csd:organization
    case "service" return $doc/csd:CSD/csd:serviceDirectory/csd:service
    default return ()

  let $first := $page * 50 + 1
  let $last := ($page +1) * 50 
  let $p_entities := $entities[csd:otherID[@assigningAuthorityName='urn:openhie.org:openinfoman' and @code='duplicate']][position() >= $first and position() <= $last]

  let $list :=
    <ul>
      {
	for $e in $p_entities
	let $url := csd_webui:generateURL( ("CSD/duplicates", $doc_name ,"manage" , string($e/@entityID)))
	let $ename :=
	  if (local-name($e) = 'provider')
	  then (($e/csd:demographic/csd:name/csd:commonName)[1])/text()
	  else $e/csd:primaryName/text()
	return <li>Manage <a href="{$url}">{$ename} [{string($e/@entityID)}]</a></li>
      }
    </ul>
  let $next := csd_webui:generateURL(( "CSD/duplicates", $doc_name ,"list-dup" , concat($entity , "?page=" , ($page +1))))
  let $prev := csd_webui:generateURL(( "CSD/duplicates", $doc_name ,"list-dup" , concat($entity , "?page=" , ($page -1))))
  let $content :=
    <div>
      <h2>Records With Duplicates</h2>
      {$list}
      <hr/>
      { if (($page) >= 1 ) then   <a href="{$prev}">Previous Page</a> else () }
      <a href="{$next}">Next Page</a>

    </div>

  return csd_webui:wrapper($content)
};



declare
  %rest:path("/CSD/duplicates/{$doc_name}/list-pot-dup/{$entity}")
  %rest:GET
  %output:method("xhtml")
  %rest:query-param("page", "{$page}", 0)
  function page:potential_duplicate_list($doc_name,$entity,$page) 
{ 
  let $doc := csd_dm:open_document($doc_name)
  let $entities:=
    switch($entity)
    case "provider" return $doc/csd:CSD/csd:providerDirectory/csd:provider
    case "facility" return $doc/csd:CSD/csd:facilityDirectory/csd:facility
    case "organization" return $doc/csd:CSD/csd:organizationDirectory/csd:organization
    case "service" return $doc/csd:CSD/csd:serviceDirectory/csd:service
    default return ()

  let $first := $page * 50 + 1
  let $last := ($page +1) * 50 
  let $p_entities := $entities[csd:otherID[@assigningAuthorityName='urn:openhie.org:openinfoman' and @code='potential-duplicate']][position() >= $first and position() <= $last]

  let $list :=
    <ul>
      {
	for $e in $p_entities
	let $url := csd_webui:generateURL(("/CSD/duplicates/", $doc_name ,"/manage/" , string($e/@entityID)))
	let $ename :=
	  if (local-name($e) = 'provider')
	  then (($e/csd:demographic/csd:name/csd:commonName)[1])/text()
	  else $e/csd:primaryName/text()
	return <li>Manage <a href="{$url}">{$ename} [{string($e/@entityID)}]</a></li>
      }
    </ul>
  let $next := csd_webui:generateURL(( "/CSD/duplicates/", $doc_name ,"/list-pot-dup/" , concat($entity , "?page=" , ($page +1))))
  let $prev := csd_webui:generateURL(( "/CSD/duplicates/", $doc_name ,"/list-pot-dup/" , concat($entity , "?page=" , ($page -1))))
  let $content :=
    <div>
      <h2>Records With Potential Duplicates</h2>
      {$list}
      <hr/>
      { if (($page) >= 1 ) then   <a href="{$prev}">Previous Page</a> else () }
      <a href="{$next}">Next Page</a>
    </div>

  return csd_webui:wrapper($content)
};




declare
  %rest:path("/CSD/duplicates/{$doc_name}/{$entity}")
  %rest:GET
  %output:method("xhtml")
  function page:duplicate_doc_entity($doc_name,$entity)
{ 
  let $pot := concat( "/CSD/duplicates/", $doc_name ,"/list-pot-dup/" , $entity)
  let $dup := concat( "/CSD/duplicates/", $doc_name ,"/list-dup/" , $entity)
  let $all := concat( "/CSD/duplicates/", $doc_name ,"/list/" , $entity)
  let $content :=
    <div>
      <h2>Manage {$entity} duplicate information on {$doc_name}</h2>
      <p>
	<a href="{csd_webui:generateURL(('CSD/duplicates',$doc_name,'list',$entity))}">List {$entity}  information for {$doc_name}</a>
      </p>
      <p>
	<a href="{csd_webui:generateURL(('CSD/duplicates',$doc_name,'list-dup',$entity))}">List {$entity} duplicate information for {$doc_name}</a>
      </p>
      <p>
	<a href="{csd_webui:generateURL(('CSD/duplicates',$doc_name,'list-pot-dup',$entity))}">List {$entity}  potential duplicate information for {$doc_name}</a>
      </p>
    </div>

  return csd_webui:wrapper($content)
};


declare
  %rest:path("/CSD/duplicates/{$doc_name}")
  %rest:GET
  %output:method("xhtml")
  function page:duplicate_doc($doc_name)
{ 
  let $content :=
    <div>
      <h2>Manage duplicate information for {$doc_name}</h2>
      {
	for $entity in ('provider','facility','organization','service')
	return 
	   <p>	
	    <a href="{csd_webui:generateURL(('CSD/duplicates',$doc_name,$entity))}">Manage {$entity} information</a>
	  </p>
      }
    </div>

  return csd_webui:wrapper($content)
};


declare
  %rest:path("/CSD/duplicates")
  %rest:GET
  %output:method("xhtml")
  function page:duplicate()
{
  let $content :=
    <div>
      <h2>Manage duplicate information on selected document</h2>
      {
	for $doc_name in csd_dm:registered_documents()
	return 
	  <p>
	    <a href="{csd_webui:generateURL(('CSD/duplicates',$doc_name))}">Manage {$doc_name} information</a>
	  </p>
      }
    </div>

  return csd_webui:wrapper($content)
};





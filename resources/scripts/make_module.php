<?php

$files = $argv;
array_shift($files);
foreach ($files as $file) {
    create_page_module($file);
}

function create_page_module($file) {
    
    $contents = file_get_contents($file);
    $dom = new DOMDocument();
    $dom->loadXML($contents);
    $dom->xinclude();


    $search = $dom->documentElement->getAttribute('urn');
    if (! $search) {
	echo "\tNo function name found\n";
	return false;
    }
    $nodes = $dom->getElementsByTagNameNS('urn:ihe:iti:csd:2013', 'definition');
    if (!$nodes instanceof DOMNodeList || $nodes->length != 1) {
	echo "\tNo defintion found\n";
	return false;
    }
    $definition = $nodes->item(0)->textContent;    
    $hash = md5($search);
    echo "Creating $file as $hash.xml\n";


    $parts = preg_split('/declare\s+variable\s+\$careServicesRequest\s+as\s+item\\(\\)\s+external\s*;/',$definition);
    if (count($parts) != 2) {
	echo "\tDeclaration of \$careServicesRequest not found\n";
	return false;
    }
    $preamble = $parts[0];
    $method = $parts[1];



    $preamble = preg_replace ('/import\s+module\s+namespace\s+csd_dm\s*=\s*["\']https:\/\/github.com\/openhie\/openinfoman\/csd_dm["\']\s*;/','',$preamble);
    $preamble = preg_replace ('/import\s+module\s+namespace\s+csd_webconf\s*=\s*["\']https:\/\/github.com\/openhie\/openinfoman\/csd_webconf["\']\s*;/','',$preamble);
    $preamble = preg_replace ('/import\s+module\s+namespace\s+csd_webui\s*=\s*["\']https:\/\/github.com\/openhie\/openinfoman\/csd_webui["\']\s*;/','',$preamble);
    $preamble = preg_replace ('/declare\s+namespace\s+csd\s*=\s*["\']urn:ihe:iti:csd:2013["\']\s*;/','',$preamble);


    $module = 
	"
module namespace page = 'http://basex.org/modules/web-page';
import module namespace csd_webconf =  \"https://github.com/openhie/openinfoman/csd_webconf\";
import module namespace csd_webui =  \"https://github.com/openhie/openinfoman/csd_webui\";
import module namespace csd_dm = \"https://github.com/openhie/openinfoman/csd_dm\";
declare  namespace csd =  \"urn:ihe:iti:csd:2013\";
" 
	.  $preamble
	.  "
declare 
  function page:worker(\$doc,\$careServicesRequest) 
{
    \$doc/(
       $method
    )
};

declare
  %rest:path(\"/CSD/csr2/{\$docname}/careServicesRequest/$search\")
  %rest:consumes(\"application/xml\", \"text/xml\", \"multipart/form-data\")  
  %rest:POST(\"{\$careServicesRequest}\")
  function page:processRequest(\$docname,\$careServicesRequest) 
{ 

  if (csd_dm:document_source_exists(\$csd_webconf:db,\$docname)) 
  then 
    let \$doc := csd_dm:open_document(\$csd_webconf:db,\$docname)
    let \$base_url := csd_webui:generateURL()
    let \$request := 
      <csd:requestParams resource=\"{\$docname}\" function=\"{$search}\" base_url=\"{\$base_url}\">
        {
        if (\$careServicesRequest/csd:requestParams) 
        then \$careServicesRequest/csd:requestParams/*
        else \$careServicesRequest/requestParams/*
        }
      </csd:requestParams>

    return page:worker(\$doc,\$request)
  else  ()

};
";

    file_put_contents($hash . '.xqm',$module);
}
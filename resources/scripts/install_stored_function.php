#!/usr/bin/php
<?php

#should be run in base directory of openinfoman install (e.g. /var/lib/openinfoman)

$exists = array('bin/basex','repo-src','webapp');
foreach ($exists as $e) {
    if (!(file_exists($e))) {
	echo("Please run in base directory of openinfoman install:\n\tCould not find $e relative to current directory\n");
	exit(1);
    }
}

$repo_src_dir = getcwd() . DIRECTORY_SEPARATOR . "repo-src";
$webapp_dir = getcwd() . DIRECTORY_SEPARATOR . "webapp";

$files = $argv;
array_shift($files);
foreach ($files as $file) {
    echo "Processing $file\n";
    if ( ! ($mods = create_modules($file))) {
	echo "\tCould not process $file\n";
	exit(2);
    }    

    #install it as a module
    $repo_src = $repo_src_dir .DIRECTORY_SEPARATOR . 'stored_function_' . $mods['name'] . '.xqm';
    file_put_contents($repo_src, $mods['sf']);
    $ret_val = 0;
    $ret = passthru("bin/basex -Vc 'REPO INSTALL $repo_src'",$ret_val);
    if ($ret_val != 0) {
	echo "\tCould not install repository\n";
	exit(3);
    }
    #put definition in the database
    if (! $mods['updating']) {
	$script = "
import module namespace csr_proc = \"https://github.com/openhie/openinfoman/csr_proc\";
declare   namespace   csd = \"urn:ihe:iti:csd:2013\";
let \$func := doc('$file')/csd:careServicesFunction
return csr_proc:load_stored_function('provider_directory',\$func)

";	
    } else {
	$script = "
import module namespace csr_proc = \"https://github.com/openhie/openinfoman/csr_proc\";
declare   namespace   csd = \"urn:ihe:iti:csd:2013\";
let \$func := doc('$file')/csd:careServicesFunction
return csr_proc:load_stored_updating_function('provider_directory',\$func)

";	
    }
    $script_file = sys_get_temp_dir() . DIRECTORY_SEPARATOR . 'install_' . $mods['name'] . '.xq';
    file_put_contents($script_file,$script);
    echo $script_file;
    $ret_val = 0;
    $ret = passthru("bin/basex -Vc 'RUN $script_file'",$ret_val);
    if ($ret_val != 0) {
	echo "\tCould not install repository\n";
	exit(3);
    }    
    #put in RESTXQ bindings
    file_put_contents($webapp_dir .DIRECTORY_SEPARATOR . 'page_' . $mods['name'] . '.xqm', $mods['page']);
}

function create_modules($file) {
    $contents = file_get_contents($file);    
    
    $cwd = getcwd();
    $dir = dirname($file);
    chdir($dir);
    $dom = new DOMDocument();
    $dom->loadXML($contents);
    $dom->xinclude();
    chdir($cwd);

    $path_parts = pathinfo($dir);
    $updating = ($path_parts['filename'] == 'stored_updating_query_definitions') ? ' updating ' : '';

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

    $sf_module = 
	"
module namespace oim-sf = 'https://github.com/openhie/openinfoman/stored-function/$search';
" 
	.  $preamble
	.  "
declare $updating
  function oim-sf:processRequest(\$doc,\$careServicesRequest) 
{
    \$doc/(
       $method
    )
};

";

    $page_module = 
	"
module namespace page = 'http://basex.org/modules/web-page';
import module namespace csd_webconf =  \"https://github.com/openhie/openinfoman/csd_webconf\";
import module namespace csd_webui =  \"https://github.com/openhie/openinfoman/csd_webui\";
import module namespace csd_dm = \"https://github.com/openhie/openinfoman/csd_dm\";
import module namespace oim-sf = \"https://github.com/openhie/openinfoman/stored-function/$search\";
declare  namespace csd =  \"urn:ihe:iti:csd:2013\";

declare $updating
  %rest:path(\"/CSD/csr/{\$docname}/careServicesRequest/$search\")
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

    return oim-sf:processRequest(\$doc,\$request)
  else  ()      (:need appropriate error handling:)

};
";



    return array(
	'page'=>$page_module,
	'sf'=>$sf_module,
	'name'=>$search,
	'updating'=>$updating
	);
}
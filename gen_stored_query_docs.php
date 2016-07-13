<?php

$cmd = 'curl -s https://api.github.com/search/repositories?q=openinfoman | grep full_name | grep openhie | awk -F\\" \'{print $4}\'' ;
$tmp_dir = '/tmp/gen_sq';
$xsl = "resources/doc_careServiceFunctions.xsl";
$repos = preg_split('/\s+/', `$cmd` ,-1,PREG_SPLIT_NO_EMPTY|PREG_SPLIT_DELIM_CAPTURE);
    


$xml = '
<careServiceFunctions 
xmlns:xforms="http://www.w3.org/2002/xforms" 
     xmlns:csd="urn:ihe:iti:csd:2013" 
     xmlns:xi="http://www.w3.org/2001/XInclude" 
     xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
     xmlns:hfp="http://www.w3.org/2001/XMLSchema-hasFacetAndProperty" 
     />
';

$bulk = new DOMDocument();
$bulk->loadXML($xml);
$xsldoc = new DOMDocument();
$xsldoc->load($xsl);
$xslproc = new XSLTProcessor();
$xslproc->importStyleSheet($xsldoc);

$cwd = getcwd();
$cmd = "mkdir -p $cwd/stored-functions";
$index ="<html><body><ul><li><a href='all.html'>All available stored functions</a></li>";



print_r($repos);
foreach ($repos as $repo) {
    echo $repo . "\n";
    list($owner,$name) = explode('/',$repo);
    if (!substr($name,0,11) == 'openinfoman') {continue;}
    $dir = $tmp_dir .'/'. $repo;
    $cmd = "mkdir -p $tmp_dir/stored-functions/$owner";
    `$cmd`;
    echo "\tChecking $dir \n";
    if (! (file_exists($dir))) {
        echo "\tCloning repo\n";
        $cmd = "cd $tmp_dir/$owner &&  git clone http://github.com/$repo";
    } else {
        echo "\tUpdating repo\n";
        $cmd = "cd $tmp_dir/$repo && git pull";
    }
    `$cmd`;
    $sing = new DOMDocument();
    $sing->loadXML($xml);
    echo "$dir/resources/stored_*query_defintions/*xml\n";
    foreach (glob("$dir/resources/stored_*query_definitions/*xml") as $sq) {
        echo "\tProcessing $sq\n";        
        chdir (dirname($sq));
        $imp = new DOMDocument();
        $imp->load($sq);
        $imp->xinclude();
        $sing->documentElement->appendChild($sing->importNode($imp->documentElement,true));
        $bulk->documentElement->appendChild($bulk->importNode($imp->documentElement,true));
    }
    $cmd = "mkdir -p $cwd/stored-functions/$owner";
    `$cmd`;
    file_put_contents("$cwd/stored-functions/$owner/$name.html", $xslproc->transformToXML($sing));
    $index .= "<li><a href='$owner/$name.html'>Stored functions</a> available in the <a href='http://github.com/$repo'>$repo Repository</a></li>";
}
$index .="</ul></body></html>";
file_put_contents("$cwd/stored-functions/index.html", $index);
file_put_contents("$cwd/stored-functions/all.html", $xslproc->transformToXML($bulk));
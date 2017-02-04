<?php
class merge {
	function __construct($host,$destination_doc) {
        $this->host = $host;
        $this->destination_doc = $destination_doc;
    }
    
    public function merge_docs ($source_doc) {
    	$csr='<csd:requestParams xmlns:csd="urn:ihe:iti:csd:2013">
					<csd:documents>
    					<csd:document resource="'.$source_doc.'"/>
					</csd:documents>
				</csd:requestParams>';
		$urn="update/urn:openhie.org:openinfoman:identifier_merge";
		$results=$this->exec_request($csr,$urn);
		echo $results;
    }
    
    protected $curl_opts = array(
	    'CURLOPT_HEADER'=>0,
	    'CURLOPT_POST'=>1,
	    'CURLOPT_HTTPHEADER'=>array('content-type'=>'content-type: text/xml'),
            'CURLOPT_RETURNTRANSFER'=>1
	    );
    
	public function exec_request($csr,$urn) {
        $curl =  curl_init($this->host . "/csr/{$this->destination_doc}/careServicesRequest/{$urn}");
        foreach ($this->curl_opts as $k=>$v)  {
                curl_setopt($curl,@constant($k) ,$v);
            }
        curl_setopt($curl, CURLOPT_POSTFIELDS, $csr);
        $curl_out = curl_exec($curl);
        if ($err = curl_errno($curl) ) {
            return false;
        }
        curl_close($curl);
        return $curl_out;
    }
}

$host="http://localhost:8984/CSD";
$dest_doc="mhero_liberia_merge";
$source_docs=array("mhero_liberia_rapidpro","mhero_liberia_ihris");
$mergeObj =  new merge($host,$dest_doc);

foreach ($source_docs as $source_doc) {
	echo "processing $source_doc\n";
	$mergeObj->merge_docs($source_doc);
}
?>

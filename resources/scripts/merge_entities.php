<html>
<head>
<link href="http://localhost:8984/static/bootstrap/css/bootstrap.css" rel="stylesheet">
<link href="http://localhost:8984/static/bootstrap/css/bootstrap-theme.css" rel="stylesheet">
<link rel="shortcut icon" href="http://localhost:8984/static/favicon.ico">
<link rel="stylesheet" type="text/css" media="screen" href="http://localhost:8984/static/bootstrap/js/tab.js">

<script type="text/javascript" src="https://code.jquery.com/jquery-1.12.4.js"></script>
<script>
function display_report(from,change_page,total_page)
{
	document.getElementById("report").innerHTML="<center><font><img width=\"70\" height=\"70\" src=\"http://localhost:8984/static/loading.gif\"></center>"
	var src_doc = document.docs.src_doc_name.value
	var target_doc = document.docs.target_doc_name.value
	var entity_type = document.docs.entity_type.value
	var max_rows = document.docs.max_rows.value
if (window.XMLHttpRequest)
  {// code for IE7+, Firefox, Chrome, Opera, Safari
  xmlhttp=new XMLHttpRequest();
  }
else
  {// code for IE6, IE5
  xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  }
xmlhttp.onreadystatechange=function()
  {
  if (xmlhttp.readyState==4 && xmlhttp.status==200)
    {
    document.getElementById("report").innerHTML=xmlhttp.responseText;    
    }
  }
  if(from=="page") {
	xmlhttp.open("GET","merge_entities_JSP.php?page="+change_page+"&total_page="+total_page+"&src_doc="+src_doc+"&target_doc="+target_doc+"&entity_type="+entity_type+"&max_rows="+max_rows,true);
  }
  else
xmlhttp.open("GET","merge_entities_JSP.php?src_doc="+src_doc+"&target_doc="+target_doc+"&entity_type="+entity_type+"&max_rows="+max_rows,true);
xmlhttp.send();
}

function show(id,level_message) {
      var label="label"+id
      if(document.getElementById(id).style.display=="inline") {
          document.getElementById(label).innerHTML="<b>+</b>Show The "+level_message
          document.getElementById(id).style.display="none"
      }
      else {
          document.getElementById(label).innerHTML="<b>-</b>Hide The "+level_message
          document.getElementById(id).style.display="inline"
      }
  }
</script>
</head>
</html>
<body>
<div class="navbar navbar-inverse navbar-static-top">
      <div class="container">
        <img class="pull-left" height="38px" style="margin-top:8px; margin-right:5px" src="http://localhost:8984/static/oim_logo_48p.png">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <table>
            <tbody><tr>
              <td>
                <a class="navbar-brand" href="http://localhost:8984/CSD">OpenInfoMan - InterLinked Health Services Registry</a>
              </td>
            </tr>
            <tr>
              <td>
                <span style="font-size:0.5em; color:white">
	        part of the iHRIS family of health workforce data solutions
		</span>
              </td>
            </tr>
          </tbody></table>
        </div>
        <span class="pull-right">
          <img src="http://localhost:8984/static/openhie.png" style="height:60px; padding-right:10px; padding-top:8px;">
        </span>
      </div>
    </div>
<form action="#" name="docs">
<center>
<table><tr>
<?php
$host="http://localhost:8984/CSD";
$docs=get_docs();
echo "<td>Source CSD Document</td><td><select name='src_doc_name'>".display_docs($docs)."</select></td>
<td>Entity Type</td><td><select name='entity_type'>
<option value='facility'>Facility</option>
<option value='provider'>Provider</option>
<option value='organization'>Organization</option>
<option value='service'>Service</option>
</select></td></tr><tr>
<td>Target CSD Document</td><td><select name='target_doc_name'>".display_docs($docs)."</select></td>
<td>Rows Per Page</td><td><select name='max_rows'>
<option>2</option>
<option>5</option>
<option>10</option>
<option selected>20</option>
<option>40</option>
<option>60</option>
<option>80</option>
<option>100</option>
<option value='all'>All</option>
</select></td>
";
?>
<td></td><td><input type='button' value='Find Dupplicates' name='set_docs' onclick='display_report("","","")'></td>
</tr></table>
</center></form>
<?php

	function get_docs() {
		global $host;
    	$csr = "<csd:requestParams xmlns:csd='urn:ihe:iti:csd:2013'>
						<adhoc>db:list('provider_directory','service_directories')</adhoc>
					 </csd:requestParams>";
		$urn = "urn:ihe:iti:csd:2014:adhoc";
		$docs=exec_request("slfacilities",$csr,$urn,$host);
		$docs=str_replace("service_directories/","",$docs);
		$docs=explode(".xml",$docs);
		return $docs;
    	}
    	
   function display_docs ($docs) {
   	$options="";
    	foreach($docs as $doc) {
    		if($doc=="")
    		continue;
    		$options=$options."<option value='$doc'>$doc</option>";
    	}
    	return $options;
   }
    
   function exec_request($doc_name,$csr,$urn,$host) {
   	$curl_opts = array(
	    'CURLOPT_HEADER'=>0,
	    'CURLOPT_POST'=>1,
	    'CURLOPT_HTTPHEADER'=>array('content-type'=>'content-type: text/xml'),
            'CURLOPT_RETURNTRANSFER'=>1
	    );
        $curl =  curl_init($host . "/csr/{$doc_name}/careServicesRequest/{$urn}");
        foreach ($curl_opts as $k=>$v)  {
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
?>
<div id="report">

</div>
<div class="footer">
      <center>
        <img src="http://localhost:8984/static/USAID_CP_IH_PEPFAR_logos.png" width="30%">
      </center>
      <div class="container">
        <div class="row">
          <div class="col-md-12">
            <!--
	    <a class='pull-right' href="http://www.youtube.com/watch?v=pBjvkHHuPHc"  style='color:rgb(0,0,0);text-decoration:none'>(tra-la-la)</a>
           -->
          </div>
        </div>
      </div>
    </div>
</body>
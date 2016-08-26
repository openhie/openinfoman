<?php
  /*
   Need to change this script and use Openinfoman CSD docs instead of mysql database
  */
?>
<script type="text/javascript">
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
<?php



abstract public  class entityMatch {
    protected $host;
    protected $doc_name;
    protected $entity_type;

    public abstract function find_matching_entities($entity_id);
    __construct($host,$doc_name,$entity_type) {
        $this->host = $host;
        $this->doc_name = $doc_name;
        $this->entity_type = $entity_type;
    };



    public function retrieve_entitiy( $entity_id) {
        $results =$this->retrieve_entities( array($entity_id));
        if (!is_array($results) || count($results) != 1 ) {
            return false;
        }
        return array_pop($results);        
    };

    protected $entity_cache = array();
    public function retrieve_entities( $entity_ids = array()) {
        $results =araray();
        foreach ($entity_ids as $entity_id) {
            if (array_key_exists($entity_id,$this->entity_cache)) {
                $entity = $this->entity_cache[$entity_id];
            } else {
                $csr = "
<csd:requestparams xmlns:csd='urn:ihe:iti:csd:2013'>
    <csd:{$this->entity_type} entityid='{$entity_id}'/> 
</csd:requestparams>";               
                $urn ="urn:ihe:iti:csd:2014:stored-function:{$this->entity_type}-search";
                $entity = $this->exec_request($csr,$urn);
                $this->entity_cache[$entity_id] = $entity;
            }
            if ($entity) {
                $results[] = $entity;
            }
        }
        return $results;
    };

        
    public function get_entity_ids( $page = 0, $page_size = 50) {
        $entity_ids = array();
        switch ($this->entity_type) {
        case 'provider':
            $urn = "urn:openhie.org:openinfoman-hwr:stored-function:health_worker_get_urns";
            break;
        case 'facility':
        case 'organization':
        case 'service':
            $urn = "urn:openhie.org:openinfoman-hwr:stored-function:{$this->entity_type}_get_urns">
        default:
            return $entity_ids;
        }
        $csr = "
<csd:requestparams xmlns:csd='urn:ihe:iti:csd:2013'>
    <csd:start>{$page}</csd:start>
    <csd:max/>{$page_size}</csd:max>
</csd:requestparams>";               
        if (! $respose = $this->exec_req($csr,$urn)) {
            return $entity_ids;
        }
        
        $response_xml = new SimpleXMLElement($entity_ids);
        $response_xml->registerXPathNamespace ( "csd" , "urn:ihe:iti:csd:2013");
        if (is_array($ids = $reposnse_xml->xpath("/csd:CSD/*/*[@entityID]"))) {
            foreach ($ids as $id) {
                $entity_id = $id->__toString();
            }
        }
        return $entity_ids;
    };

    public is_marked_duplicate($id1,$id2 ) {
        $entity1 = $this->retrieve_entity($id1);
        if ($this->extract($entity1,"/csd:otherID[@assigningAuthorityName='urn:openhie.org:openinfoman' and @code='duplicate' and ./text()='{$id2}']")) {
            return true;
        } else {
            return false;
        }
    };


    public is_marked_not_duplicate($id1,$id2 ) {
        $entity1 = $this->retrieve_entity($id1);
        if ($this->extract($entity1,"/csd:otherID[@assigningAuthorityName='urn:openhie.org:openinfoman' and @code='not-duplicate' and ./text()='{$id2}']")) {
            return true;
        } else {
            return false;
        }
    };

    protected $entity_xml_cache = array();
    public function extract($entity,$xpath,$implode = true) {
        if (array_key_exists($entity,$entity_xml_cache)) {
            $entity_xml = $this->entity_xml_cache;
        } else {
            $entity_xml = new SimpleXMLElement($entity);
            $entity__xml->registerXPathNamespace ( "csd" , "urn:ihe:iti:csd:2013");
            $this->entity_xml_cache[$entity] = $entity_xml;
        }
        $xpath_pre = "(/csd:CSD/*/csd:{$this->entity_type})[1]";
        $results =  $entity_xml->xpath($xpath_pre . $xpath);
        if ($implode && is_array($results)) {
            $results = implode($results);
        }
        return $results;
    };
    protected $curl_opts = array(
	    'HEADER'=>0,
	    'POST'=>1,
	    'HTTPHEADER'=>array('content-type'=>'content-type: text/xml'),
            'CURLOPT_RETURNTRANSFER'=>1
	    );
    protected $curl =null;
    public function exec_request($csr,$urn) {
        if ( ! is_resource($this->curl)) {
            $this->curl =  curl_init($this->host);
            foreach ($this->curl_opts as $k=>$v)  {
                curl_setopt($this->curl,@costant($k) ,$v);
            }
        }
        curl_setopt($ch, CURLOPT_POSTFIELDS, $csr);
        $curl_out = curl_exec($ch);
        if ($err = curl_errno($ch) ) {
            return false;
        }
        return $curl_out;
    };
  }


public class entityMatchPotentialDuplicates extends entityMatch {

    public function find_matching_entities($entity_id) {
        switch ($this->entity_type) {
        case 'organization':
        case 'facility':
            $name_path = array(
                "(/csd:{$this->entity_type}/csd:primaryName || /csd:{$this->entity_type}/csd:otherName)[1]";
                break;
            case 'provider':
                $name_path =  "(/csd:provider/csd:demographic/csd:name/csd:commonName)[1]";
                break;
            default:
                return array();
                }
        }
        $rankings =array(0=>$this->get_potential_duplicates($entity_id)); //flat rankings - no preference in these
        return $rankings;
    }

    public function get_potential_duplicates($entity_id) {
        $entity1 = $this->retrieve_entity($id1);
        if (is_array($results = $this->extract($entity1,"/csd:otherID[@assigningAuthorityName='urn:openhie.org:openinfoman' and @code='potential-duplicate']"))) {
            $dups = array();
            foreach ($results as $result) {
                $dups[] = $result->__toString();
            }
            return $dups;
        } else {
            return false;
        }
    }

}
      
public class entityMatchLevenshtein extends entityMatch {
    public function find_matching_entities($entity_id) {
        switch ($this->entity_type) {
        case 'organization':
        case 'facility':
            $name_path = 
                "/csd:{$this->entity_type}/csd:primaryName || /csd:{$this->entity_type}/csd:otherName";
            break;
        case 'provider':
            $name_path =  "/csd:provider/csd:demographic/csd:name/csd:commonName";
            break;
        default:
            return array();
            
        }
        $entity = $this->retrieve_entity($entity_id);
        $entity_names = $this->extract($entity,$name_path,false);
        foreach ($entity_names as $entity_name) {
            $entity_name = trim(strtolower($entity_name));
        }
        $entity_name = null;

        $rankings = array();
        foreach ($this->get_entitiy_ids(0, -1) as $other_entity_id) {
            if ($this->is_marked_duplicate($entity_id,$entity_other_id)
                || $this->is_marked_not_duplicate($entity_id,$entity_other_id)) {
                continue;
            }
            foreach ($namepaths as $namepath) {
                $other_entity = $this->retrieve_entity($other_entity_id);
                $other_entity_names = $this->extract($other_entity,$name_path);
                foreach ($other_entity_names as $other_enity_name) {
                    $other_entity_name = trim(strtolower($other_entity_name));
                    foreach ($entity_names as $entity_name) {
                        $lev = levenshtein($entity_name,$other_entity_name);
                        if (!array_key_exists($lev,$rankings)) {
                            $rankings[$lev] = array();
                        }
                        $rankings[$lev][$other_entity_id] = $other_entity_name;
                    }
                }
            }
        }
        return $rankings;
    }
}



$count=0;
$counter=0;
if($_SERVER["REQUEST_METHOD"]=="POST") {
    foreach($_POST["dhis2"] as $ihris=>$dhis2) {
	$data=mysql_query("select * from `dhis2-ihris` where ihris='$ihris'") or die(mysql_error());
	if(mysql_num_rows($data)>0)
            mysql_query("update `dhis2-ihris` set dhis2='$dhis2' where ihris='$ihris'") or die(mysql_error());
	else
            mysql_query("insert into `dhis2-ihris` (ihris,dhis2) values ('$ihris','$dhis2')") or die(mysql_error());
    }
    foreach($_POST["comment"] as $ihris_id=>$comment) {
	if(!$comment)
            continue;
        $data=mysql_query("select * from `dhis2-ihris-comments` where ihris_id='$ihris_id'") or die(mysql_error());
        if(mysql_num_rows($data)>0)
            mysql_query("update `dhis2-ihris-comments` set comment='$comment' where ihris_id='$ihris_id'") or die(mysql_error());
        else
            mysql_query("insert into `dhis2-ihris-comments` (ihris_id,comment) values ('$ihris_id','$comment')") or die(mysql_error());
    }
    echo "<b>Data is saved successfully</b><br>";
    echo "<a href='merge_facilities.php'>Return</a>";
}
else 
{
    $max_rows=100;
    if (isset($_GET['page']))  
    {
        $page=$_GET['page'];
        $total_page=$_GET['total_page'];
        $count=$_GET['count'];
    }
    else
    {
        $page=0;
        $count=0;
    }
    $first_row=$page*$max_rows;
    $ihris_facilities=mysql_query("select * from iHRIS_SL_Facility");
    $total_rows=mysql_num_rows($ihris_facilities);
    $total_page=ceil($total_rows/$max_rows)-1;
    $results=$entity_match->retrieve_entities($first_row,$max_rows);
    $count=$first_row;
    $match=array("1<sup>st</sup> Best Matches","2<sup>nd</sup> Best Matches","3<sup>rd</sup> Best Matches","4<sup>th</sup> Best Matches","5<sup>th</sup> Best Matches");
    $colors=array("FF3333","FF8633","6EBB07","07BBB6","0728BB");
    echo "<form method='POST' action='#'>";
    echo "<center><u><b><font color='green'>Page Number ".($page+1)."/".($total_page+1)."</font><font color='orange'> Showing ".mysql_num_rows($results)."/".$total_rows." Records</b><p></u>";
    echo "<table><tr>";
    if($page>0)
    {
        echo"<td><a href='merge_facilities.php?page=0&total_page=$total_page&count=$count' title='First Page'> |< First &nbsp;</a> &nbsp; &nbsp;</td>";
    }
    $next=$page+1;
    if($page<$total_page)
    {
        echo"<td><a href='merge_facilities.php?page=$next&total_page=$total_page&count=$count' title='Next Page'> Next >> &nbsp;</a> &nbsp; &nbsp;</td>";
    }
    $prev=$page-1;
    if ($page>0)
    {
        echo"<td><a href='merge_facilities.php?page=$prev&total_page=$total_page&count=$count' title='Previous Page'> << Previous &nbsp;</a> &nbsp; &nbsp;</td>";
    }
    if($page<$total_page)
    {
        echo"<td><a href='merge_facilities.php?page=$total_page&total_page=$total_page&count=$count' title='Last Page'> Last >| &nbsp;</a> &nbsp; &nbsp;</td>";
    }
    ##########   end displaying navigations ##################
    echo "<td align='center'><input type='submit' name='submited' value='Save'></td></tr>";
    echo "</table>";
    echo "<table border='1' cellspacing='0'><tr><th>SN</th><th>iHRIS Facility</th><th>DHIS2 Exact Match</th><th>DHIS2 Manually Matched</th><th>Match Comments</th><th>DHIS2 Close Match</th></tr>";

    /**
     *  
     * TO DO :  Replace the logic below with display logic based on the following:
     * $page = 
     * $doc_name = $_GET['doc_name'];
     * $host = "http://localhost:8984/CSD";
     * $entity_match = new entityMatchLevenshtein($host,$doc_name,"facility");
     * foreach ($entity_match->get_entity_ids( $page , $max_rows) as $entity_id) {
     *   $rankings = $entity_match->find_matching_entities($entity_id);
     *   
     *   // INSERT DISPLAY AND HTML FORM LOGIC HERE
     *
     * }
     *    
     */

    while($row=mysql_fetch_array($results)) {
	$strs=explode(" ",$row["name"]);
	foreach($strs as $k=>$str)
            if($str=="")
                unset($strs[$k]);
	$row["name"]=implode(" ",$strs);
	$count++;
	$shortest = -1;
	$closest=array();
	$results1=mysql_query("select * from hippo_csd_facility");
	while($row1=mysql_fetch_array($results1)) {
            $mapped=mysql_query("select dhis2 from `dhis2-ihris` where dhis2='$row1[id]'");
            if(mysql_num_rows($mapped)>0)
		continue;
            $strs=explode(" ",$row1["primary_name"]);
            foreach($strs as $k=>$str)
                if($str=="")
                    unset($strs[$k]);
            $row1["primary_name"]=implode(" ",$strs);
            if(count($strs)==2) {
                $str1=implode(" ",$strs);
                $str2=$strs[1]." ".$strs[0];
                $lev1 = levenshtein(trim(strtolower($row["name"])),trim(strtolower($str1)));
                $lev2 = levenshtein(trim(strtolower($row["name"])),trim(strtolower($str2)));
                if($lev1<$lev2)
                    $lev=$lev1;
                else
                    $lev=$lev2;
            }
            else
		$lev = levenshtein(trim(strtolower($row["name"])), trim(strtolower($row1["primary_name"])));
            if ($lev == 0) {
    		$closest=array();
    		if(count($closest)>0) {
                    $lev1=levenshtein(trim(strtolower($row["name"])),trim(strtolower(current($closest))));
                    if($lev1==$lev)
                        $closest[$lev][$row1["id"]]=$row1["primary_name"];
                    else {
                        $closest=array();
                        $closest[$lev][$row1["id"]]=$row1["primary_name"];
                    }
        	}
        	else
                    $closest[$lev][$row1["id"]]=$row1["primary_name"];
                $shortest = 0;
        	break;
            }
		
            if(count($closest)==0)
                $closest[$lev][$row1["id"]]=$row1["primary_name"];
            else {
                if(array_key_exists($lev,$closest) or count($closest)<5) {
                    $closest[$lev][$row1["id"]]=$row1["primary_name"];
                }
            l    else {
                    $existing_levs=array_keys($closest);
                    $max=max($existing_levs);
                    if($lev<$max) {
                        unset($closest[$max]);
                        $closest[$lev][$row1["id"]]=$row1["primary_name"];
                    }
                }
            }
		
	}
	list($comment)=mysql_fetch_array(mysql_query("select comment from `dhis2-ihris-comments` where ihris_id='$row[id]'"));
	echo "<tr><td>$count</td><td><input type='hidden' name=ihris[".$row["id"]."] value=".$row["id"].">".$row["name"]."</td>";
	$dhis2_manually_mapped_name="";
	list($dhis2_manually_mapped_id)=mysql_fetch_array(mysql_query("select dhis2 from `dhis2-ihris` where ihris='$row[id]' and dhis2!='0'"));
	if($dhis2_manually_mapped_id)
            list($dhis2_manually_mapped_name)=mysql_fetch_array(mysql_query("select primary_name from hippo_csd_facility where id='$dhis2_manually_mapped_id'"));
	if ($shortest == 0) {
            $counter++;
            echo "<td>";
            foreach($closest as $lev=>$closest_pull)
                foreach($closest_pull as $id=>$close)
                echo $close."<br>";
            echo "</td><td></td><td><textarea name=comment[".$row["id"]."] style='color:green;font-weight:bold'>$comment</textarea></td><td></td>";
	}
	else {
            echo "<td></td>";
            if($dhis2_manually_mapped_name)
		echo "<td>$dhis2_manually_mapped_name</td>";
            else
		echo "<td></td>";
            echo "<td><textarea name=comment[".$row["id"]."] style='color:green;font-weight:bold'>$comment</textarea></td>";
            echo "<td>";
            ksort($closest);
            $match_index=0;
            foreach($closest as $lev=>$closest_pull) {
   		$level_message=$match[$match_index];
   		list($fac_form,$ihris_fac_id)=explode("|",$row["id"]);
   		echo "<font color='$colors[$match_index]'><label id=label$lev$ihris_fac_id onclick='show($lev$ihris_fac_id,`$level_message`)'><b>+</b>Show The $level_message</label><br><div id='$lev$ihris_fac_id' style='display:none'>";
   		foreach($closest_pull as $id=>$close) {
                    $data=mysql_query("select * from `dhis2-ihris` where dhis2='$id' and ihris='$row[id]'");
                    if(mysql_num_rows($data)>0)
   			echo "<input type='radio' checked name='dhis2[".$row["id"]."]' value='$id'>$close<br>";
                    else
   			echo "<input type='radio' name='dhis2[".$row["id"]."]' value='$id'>$close<br>";
   		}
   		echo "</div></font>";
   		$match_index++;
            }
            $data=mysql_query("select * from `dhis2-ihris` where ihris='$row[id]' and dhis2='0'");
            if(mysql_num_rows($data)>0)
                echo "<input type='radio' name='dhis2[".$row["id"]."]' value='0' checked>No Match<br>";
            else
                echo "<input type='radio' name='dhis2[".$row["id"]."]' value='0'>No Match<br>";
            echo "</td></tr>";
	}
    }

    ###########  displaying navigations  next,previous,last,first ############
    echo "</table><table><tr>";
    if($page>0)
    {
        echo"<td><a href='merge_facilities.php?page=0&total_page=$total_page&count=$count' title='First Page'> |< First &nbsp;</a> &nbsp; &nbsp;</td>";
    }
    $next=$page+1;
    if($page<$total_page)
    {
        echo"<td><a href='merge_facilities.php?page=$next&total_page=$total_page&count=$count' title='Next Page'> Next >> &nbsp;</a> &nbsp; &nbsp;</td>";
    }
    $prev=$page-1;
    if ($page>0)
    {
        echo"<td><a href='merge_facilities.php?page=$prev&total_page=$total_page&count=$count' title='Previous Page'> << Previous &nbsp;</a> &nbsp; &nbsp;</td>";
    }
    if($page<$total_page)
    {
        echo"<td><a href='merge_facilities.php?page=$total_page&total_page=$total_page&count=$count' title='Last Page'> Last >| &nbsp;</a> &nbsp; &nbsp;</td>";
    }
    ##########   end displaying navigations ##################
    echo "<td align='center'><input type='submit' name='submited' value='Save'></td></tr>";
    echo "</table></form>";
}

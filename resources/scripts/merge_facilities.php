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
mysql_connect("localhost","uname","passwd");
mysql_select_db("ihris_db");
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
else {
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
$results=$ihris_facilities=mysql_query("select * from iHRIS_SL_Facility limit $first_row,$max_rows");
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
			else {
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
?>

module namespace page = 'http://basex.org/modules/web-page';


import module namespace csd_psd = "https://github.com/his-interop/openinfoman/csd_psd" at "../repo/csd_poll_service_directories.xqm";


declare
  %rest:path("/CSD/pollService/get/{$name}")
  %rest:GET
  function page:poll_service($name)
{ 
 csd_psd:poll_service_directory($name)
};



declare
  %rest:path("/CSD/pollService")
  %rest:GET
  %output:method("xhtml")
  function page:poll_service_list()
{ 
<html>
  <body>
    <h2>Service Directories</h2>
    <ul>
      {for $srvc_dir in $csd_psd:services_library//serviceDirectory
      order by $srvc_dir/@name
      return 
      <li>
	<b>{text{$srvc_dir/@name}}</b>: <a href="/CSD/pollService/get/{$srvc_dir/@name}"> Get Directory</a>  
      </li>
      }
    </ul>
  </body>
</html>

};

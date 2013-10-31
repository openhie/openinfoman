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
  %rest:path("/CSD/pollService/get_soap/{$name}")
  %rest:GET
  function page:poll_service_soap($name)
{ 
 csd_psd:get_service_directory_soap_request($name)
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
      {for $name in csd_psd:get_services()
      let $url := csd_psd:get_service_directory_url($name)
      order by $name
      return 
      <li>
	<b>{$name}</b>: <a href="/CSD/pollService/get/{$name}"> Get Directory Contents</a> /  <a href="/CSD/pollService/get_soap/{$name}"> Get Soap Request</a>    
	To test submission on your machine you can do:
	<pre>
	curl --form "fileupload=@soap.xml" {$url}
	</pre>
	or 
	<pre>
	curl -X POST -d @soap.xml {$url}
	</pre>
	where soap.xml is  the downloaded soap request document
 
      </li>
      }
    </ul>
  </body>
</html>

};

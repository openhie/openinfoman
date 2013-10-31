module namespace page = 'http://basex.org/modules/web-page';


import module namespace csd_psd = "https://github.com/his-interop/openinfoman/csd_psd" at "../repo/csd_poll_service_directories.xqm";
import module namespace request = "http://exquery.org/ns/request";

declare
  %rest:path("/CSD")
  %rest:GET
  %output:method("xhtml")

  function page:list_functionality()
{ 
<html>
  <h2>Welcome to OpenInfoMan</h2>
  OpenInfoMan is XQuery and RESTXQ based implementation of the Care Services Directory profile from <a href="http://ihe.net">IHE</a> which implements the following actors an d transactions:
  <ul>
  <li>Info Manager : AdHoc and Stored Queries Tranactions</li>
  <li>Services Directory : Get Updated Services Transaction</li>
  </ul>
  Top-Level Endpoints:
  <ul>
  <li>Endpoint for submitting careServiceRequest documents http://{request:hostname()}:{request:port()}/careServiceRequest</li>
  <li>Endpoint for submitting getUpdatedServices soap request http://{request:hostname()}:{request:port()}/getUpdatedServices</li>
  <li><a href="http://{request:hostname()}:{request:port()}/CSD/pollService">poll registered service directories </a></li>
  <li><a href="http://{request:hostname()}:{request:port()}/CSD/test">test of careServiceRequest </a></li>
  </ul>
  <a href="http://www.youtube.com/watch?v=pBjvkHHuPHc"  style='color:rgb(0,0,0);text-decoration:none'>(tra-la-la)</a>
</html>
};


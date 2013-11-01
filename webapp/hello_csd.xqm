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
  <b>OpenInfoMan</b> is XQuery and RESTXQ based implementation of the Care Services Directory (<a href="ftp://ftp.ihe.net/DocumentPublication/CurrentPublished/ITInfrastructure/IHE_ITI_Suppl_CSD.pdf">CSD</a>) profile from <a href="http://ihe.net">IHE</a> which implements the following actors and transactions:
  <ul>
  <li><i>Info Manager</i> : Find Matching Services (Ad-Hoc and Stored) [ITI-73]</li>
  <li><i>Services Directory</i> : Query for  Updated Services Transaction [ITI-74]</li>
  </ul>
  <p><b>OpenInfoMan</b> has been developed as part of <a href="http://ohie.net">OpenHIE</a> and is intended to be the engine behind the CSD compliant <a href="https://groups.google.com/forum/#!forum/provider-registry">Provider Registry</a> and to be incorporated in <a href="http://openhim">OpenHIM</a>.
  </p>

  <p>These the top-level endpoints are exposed</p>
  <ul>
  <li>Endpoint for submitting careServiceRequest documents <i>http://{request:hostname()}:{request:port()}/CSD/careServiceRequest</i></li>
  <li>Endpoint for submitting getUpdatedServices soap request <i>http://{request:hostname()}:{request:port()}/CSD/getUpdatedServices</i></li>
  <li><a href="http://{request:hostname()}:{request:port()}/CSD/pollService">poll registered service directories </a></li>
  <li><a href="http://{request:hostname()}:{request:port()}/CSD/test">list of test careServiceRequests </a></li>
  </ul>
  <a href="http://www.youtube.com/watch?v=pBjvkHHuPHc"  style='color:rgb(0,0,0);text-decoration:none'>(tra-la-la)</a>
</html>
};


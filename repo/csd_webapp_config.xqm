(:~
: This is a module conttaining configuration options for the openinfoman webap
: @version 1.0
: @see https://github.com/openhie/openinfoman @see http://ihe.net
:
:)

module namespace csd_webconf = "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace request = "http://exquery.org/ns/request";


(:Database we are working on:)
declare variable $csd_webconf:db :=  'provider_directory';

(:BASE URL for openinforman. Overwrite this if you are proxying the openinfoman.   :)
declare variable $csd_webconf:baseurl :=  concat(request:scheme(),"://",request:hostname(),":",request:port(), "/"); 


declare variable $csd_webconf:remote_services := ()

(:
<serviceDirectoryLibrary>
  <serviceDirectory  name='rhea_simple_provider' url='http://rhea-pr.ihris.org/providerregistry/getUpdatedServices'/>
  <serviceDirectory   name='openinfoman_providers'  url='http://csd.ihris.org:8984/CSD/getUpdatedServices/providers/get'/>
  <serviceDirectory   name='openhim_providers'  url='https://openhim.jembi.org:5000/CSD/getUpdatedServices/providers/get'>
    <credentials type='basic_auth' username='test'  password='test'  />
  </serviceDirectory>
  <serviceDirectory   name='openhim_old'  url='https://openhim.jembi.org:5000/CSD/getUpdatedServices'>
    <credentials type='basic_auth' username='test'  password='test'  />
  </serviceDirectory>
</serviceDirectoryLibrary>;
:)



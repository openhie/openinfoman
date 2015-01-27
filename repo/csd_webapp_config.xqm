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

declare variable $csd_webconf:remote_services :=
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



declare function csd_webconf:wrapper($content) {
  csd_webconf:wrapper($content,())
};


declare function csd_webconf:wrapper($content,$headers) {
 <html >
  <head>
    <link href="{$csd_webconf:baseurl}static/bootstrap/css/bootstrap.css" rel="stylesheet"/>
    <link href="{$csd_webconf:baseurl}static/bootstrap/css/bootstrap-theme.css" rel="stylesheet"/>
    <link rel="shortcut icon" href="{$csd_webconf:baseurl}static/favicon.ico"/>
    <script src="{$csd_webconf:baseurl}static/jquery/jquery.js"/>
    <title>OpenInfoMan @ {request:hostname()}</title>
    <script src="{$csd_webconf:baseurl}static/bootstrap/js/bootstrap.min.js"/>
    {$headers}
  </head>
  <body>  
    <div class="navbar navbar-inverse navbar-static-top">
      <div class="container">
	<img class='pull-left' height='38px' src="{$csd_webconf:baseurl}static/GeoGebra_icon_geogebra.png"/>
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="{$csd_webconf:baseurl}CSD">OpenInfoMan - Interlinked Health Services Discovery</a>
        </div>
	<img  class='pull-right' src='https://ohie.org/wp-content/uploads/2014/11/logoHD.fw-whitefont-300x64.png' style='height:3.5em'/>
      </div>
    </div>
    <div class='container'> {$content}</div>
    <div class="footer">
      <center>
      
	<img src="{$csd_webconf:baseurl}static/USAID_CP_IH_PEPFAR_logos.png" width='30%'/>

      </center>

      <div class="container">
	<div class='row'>
	  <div class="col-md-12">
	    <a class='pull-right' href="http://www.youtube.com/watch?v=pBjvkHHuPHc"  style='color:rgb(0,0,0);text-decoration:none'>(tra-la-la)</a>
	  </div>
	</div>
      </div>
    </div>

  </body>
 </html>
};






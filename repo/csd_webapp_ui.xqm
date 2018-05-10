(:~
: This is a module conttaining configuration options for the openinfoman webap
: @version 1.0
: @see https://github.com/openhie/openinfoman @see http://ihe.net
:
:)

module namespace csd_webui = "https://github.com/openhie/openinfoman/csd_webui";
import module namespace functx = "http://www.functx.com";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace request = "http://exquery.org/ns/request";
import module namespace restxq = "http://exquery.org/ns/restxq";

declare function csd_webui:generateURL() {
  csd_webui:generateURL(())
};

declare function csd_webui:generateURL($end) {
  let $cend :=
    string-join(
      for $e in $end
      return replace(replace(string($e),'^/+',''),'/+$','')
      ,'/')
    
  let $cbegin :=
    if (functx:all-whitespace($csd_webconf:baseurl))
    then concat(request:scheme(),"://",request:hostname(),":",request:port())
    else replace($csd_webconf:baseurl, '/+$', '')
      
  return concat($cbegin,'/',$cend)

};




declare function csd_webui:nocache($response) 
{(
  <rest:response>
    <http:response >
      <http:header name="Cache-Control" value="must-revalidate,no-cache,no-store"/>
    </http:response>
  </rest:response>
  ,
  $response
)};



declare function csd_webui:redirect() as element(restxq:redirect) {
  csd_webui:redirect(())
};

declare function csd_webui:redirect($end ) as element(restxq:redirect)
{
  <restxq:redirect>{ csd_webui:generateURL($end) }</restxq:redirect>
};


declare updating function csd_webui:redirect_out() {
  csd_webui:redirect_out(())
};

declare updating function csd_webui:redirect_out($end ) {
  db:output(<restxq:redirect>{ csd_webui:generateURL($end)}</restxq:redirect>)
};





declare function csd_webui:wrapper($content) {
  csd_webui:wrapper($content,())
};


declare function csd_webui:wrapper($content,$headers) {
 <html >
  <head>
    <link href="{csd_webui:generateURL('static/bootstrap/css/bootstrap.css')}" rel="stylesheet"/>
    <link href="{csd_webui:generateURL('static/bootstrap/css/bootstrap-theme.css')}" rel="stylesheet"/>
    <link rel="shortcut icon" href="{csd_webui:generateURL('static/favicon.ico')}"/>
    <script src="{csd_webui:generateURL('static/jquery/jquery.js')}"/>
    <title>OpenInfoMan @ {request:hostname()}</title>
    <script src="{csd_webui:generateURL('static/bootstrap/js/bootstrap.min.js')}"/>
    {$headers}
  </head>
  <body>  
    <div class="navbar navbar-inverse navbar-static-top">
      <div class="container">
	<img class='pull-left' height='38px' style='margin-top:8px; margin-right:5px' src="{csd_webui:generateURL('static/oim_logo_48p.png')}"/>
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
	  <table>
	    <tr>
	      <td>
		<a class="navbar-brand" href="{csd_webui:generateURL('CSD')}">OpenInfoMan - InterLinked Health Services Registry</a>
	      </td>
	    </tr>
	    <tr>
	      <td >
		<span style='font-size:0.5em; color:white'>
	        part of the iHRIS family of health workforce data solutions
		</span>
	      </td>
	    </tr>
	  </table>
        </div>
	<span class='pull-right'>
	  <img src="{csd_webui:generateURL('static/openhie.png')}" style='height:60px; padding-right:10px; padding-top:8px;'/>
	</span>

      </div>
    </div>
    <div class='container'> {$content}</div>
    <div class="footer">
      <center>
      
	<img src="{csd_webui:generateURL('static/USAID_CP_IH_PEPFAR_logos.png')}" width='30%'/>
      </center>

      <div class="container">
	<div class='row'>
	  <div class="col-md-12">
	  <!--
	    <a class='pull-right' href="http://www.youtube.com/watch?v=pBjvkHHuPHc"  style='color:rgb(0,0,0);text-decoration:none'>(tra-la-la)</a>
           -->
	  </div>
	</div>
      </div>
    </div>

  </body>
 </html>
};






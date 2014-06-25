(:~
: This is the Care Services Discovery base XQuery module
: @version 1.0
: @see http://ihe.net
:
:)
module namespace csd_blu = "https://github.com/his-interop/openinfoman/csd_blu";
import module namespace csd_bl = "https://github.com/his-interop/openinfoman/csd_bl";

declare default element  namespace   "urn:ihe:iti:csd:2013";


declare updating function csd_blu:wrap_updating_providers($providers) 
{
  db:output(
    (
    <rest:response>
      <http:response status="200" >
	<http:header name="Content-Type" value="text/xml"/>
      </http:response>
      </rest:response>,
      csd_bl:wrap_providers($providers)
      )
     )
};

declare updating function csd_blu:wrap_updating_services($services) 
{
  db:output(
    (
    <rest:response>
      <http:response status="200" >
	<http:header name="Content-Type" value="text/xml"/>
      </http:response>
      </rest:response>,
      csd_bl:wrap_services($services)
      )
     )
};



declare updating function csd_blu:bump_timestamp($provider) {
  if (exists($provider/record/@updated)) then replace value of node $provider/record/@updated with current-dateTime() else ()
};


declare updating function csd_blu:wrap_updating_organizations($organizations) 
{
  db:output(
    (
    <rest:response>
      <http:response status="200" >
	<http:header name="Content-Type" value="text/xml"/>
      </http:response>
      </rest:response>,
      csd_bl:wrap_organizations($organizations)
      )
     )
};

declare updating function csd_blu:wrap_updating_facilities($facilities) 
{
  db:output(
    (
    <rest:response>
      <http:response status="200" >
	<http:header name="Content-Type" value="text/xml"/>
      </http:response>
      </rest:response>,
      csd_bl:wrap_facilities($facilities)
      )
     )
};

(:~
: This is the Care Services Discovery base XQuery module
: @version 1.0
: @see http://ihe.net
:
:)
module namespace csd_blu = "https://github.com/his-interop/openinfoman/csd_blu";
import module namespace csd = "urn:ihe:iti:csd:2013" at "csd_base_library.xqm";

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
      csd:wrap_providers($providers)
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
      csd:wrap_services($services)
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
      csd:wrap_organizations($organizations)
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
      csd:wrap_facilities($facilities)
      )
     )
};

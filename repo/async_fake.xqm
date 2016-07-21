module namespace async = "http://basex.org/modules/async";
import module namespace xquery = " http://basex.org/modules/xquery";

(:this module is only here to deal with upgrading from 8.5.1 , in particular for openinfoman-dhis :)

declare function async:fork-join($funcs) {
  xquery:fork-join($funcs)
};
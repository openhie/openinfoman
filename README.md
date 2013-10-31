OpenInfoMan
===========

Reference Implementation of InfoManager actor in Care Services Discovery (CSD) using RESTXQ.

This is currently being tested on BaseX.  Simply copy/link the files under:
- repo/
- webapp/
- test_docs/

Start BaseX HTTP and you will have these endpoints:
- http://localhost:8984/CSD a hello page 
- http://localhost:8984/CSD/careServicesRequest end point for the careServicesRequest
- http://localhost:8984/CSD/getUpdatedServices end point for get updated services transaction 
- http://localhost:8984/CSD/careServicesRequest/test  a list of test care services request
- http://localhost:8984/CSD/pollService  a list of registered service directories to poll for updated services
 

(tra-la-lah)

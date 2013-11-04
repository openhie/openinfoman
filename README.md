OpenInfoMan
===========

OpenInfoMan is XQuery and RESTXQ based implementation of the Care Services Directory (CSD) profile from IHE which implements the following actors and transactions:

    Info Manager : Find Matching Services (Ad-Hoc and Stored) [ITI-73]
                   Query for Updated Services Transaction [ITI-74]
    Services Directory : Query for Updated Services Transaction [ITI-74]

OpenInfoMan has been developed as part of <a href="http://ohie.org">OpenHIE</a> and is intended to be the engine behind the CSD compliant <a href="https://wiki.ohie.org/display/SUB/Provider+Registry+Community">Provider Registry</a> and to be incorporated in <a href="http://openhim/">OpenHIM</a>.


Installation
============
Downloand the most current verion of <a href="http://basex.org">BaseX</a> and simply copy/link the files under:
- repo/
- webapp/
- test_docs/
to the root directory of the basex.


Endpoints
=========
Starting BaseX HTTP and you will have these endpoints expose at the top-level

- Hello and welcome to CSD  http://localhost:8984/CSD
- Endpoint for submitting careServiceRequest documents http://localhost:8984/CSD/careServiceRequest
- Endpoint for submitting getUpdatedServices soap request http://localhost:8984/CSD/getUpdatedServices
- poll registered service directories http://localhost:8984/CSD/pollService
- administer local cache of registered service directories http://localhost:8984/CSD/cacheService
- list of test careServiceRequests http://localhost:8984/CSD/test
 
(tra-la-la)

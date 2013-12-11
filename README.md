OpenInfoMan
===========

OpenInfoMan is XQuery and RESTXQ based implementation of the Care Services Directory (CSD) profile from IHE which implements the following actors and transactions:

    Info Manager : Find Matching Services (Ad-Hoc and Stored) [ITI-73]
                   Query for Updated Services Transaction [ITI-74]
    Services Directory : Query for Updated Services Transaction [ITI-74]

OpenInfoMan has been developed as part of <a href="http://ohie.org">OpenHIE</a> and is intended to be the engine behind the CSD compliant <a href="https://wiki.ohie.org/display/SUB/Provider+Registry+Community">Provider Registry</a> and to be incorporated in <a href="http://openhim.org/">OpenHIM</a>.


Installation
============
Downloand the most current version of <a href="http://basex.org">BaseX</a> (the .zip version) and simply copy/link the files under:
- repo/
- webapp/
- webapp/static
- test_docs/
to the root directory of the basex.

Database
========
You will also need to create a database  get things working. To do this navigate to basex/bin and execute the following:

  `./basex -Vc "CREATE DATABASE provider_directory"`
  
You can use a different database by editing the repo/csd_webapp_config.xqm file and changing the value of $csd_webconf:db

Base URL
========
If OpenInfoMan is intened to work behind a proxy you will need to specify the public-facing base url by editing the repo/csd_webapp_config.xqm file and changing the value of $csd_webconf:baseurl

Stored Function Libraries
=========================
OpenInfoMan is intended to provide a core set of functionality to meet the CSD specification.  Other functionality is expected to be added through libraries of stored funcitons.
-nacesnt provider registry library https://github.com/his-interop/openinfoman-pr

Endpoints
=========
Starting BaseX HTTP and you will have these endpoints expose at the top-level

- Hello and welcome to CSD  http://localhost:8984/CSD
- Endpoint for submitting careServiceRequest documents http://localhost:8984/CSD/careServiceRequest
- Endpoint for submitting getUpdatedServices soap request http://localhost:8984/CSD/getUpdatedServices
- poll registered service directories http://localhost:8984/CSD/pollService
- administer local cache of registered service directories http://localhost:8984/CSD/cacheService
- list of test careServiceRequests http://localhost:8984/CSD/test

To Do
=====
- [ ] Validate incoming SOAP documents before processing
- [ ] Validate incoming CSD documents before caching
- [ ] Merge polled service directory into one directory
- [ ] Validate interlinked entries (e.g. does the facility that a provider record points to really exist) on merged directory
- [ ] Record @sourceDirectory attribute from polled services directory in the merged directory
- [ ] Figure out how to package things better
- [ ] Figure out how to set configuration options better (e.g. database name, polled service directories, base URL) 
 
(tra-la-la)

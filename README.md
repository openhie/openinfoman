OpenInfoMan
===========

OpenInfoMan is XQuery and RESTXQ based implementation of the <a href="http://wiki.ihe.net/index.php?title=Care_Services_Discovery">Care Services Directory (CSD)</a> profile from IHE which implements the following actors and transactions:

    Info Manager : Find Matching Services (Ad-Hoc and Stored) [ITI-73]
                   Query for Updated Services Transaction [ITI-74]
    Services Directory : Query for Updated Services Transaction [ITI-74]

OpenInfoMan has been developed as part of <a href="http://ohie.org">OpenHIE</a> and is intended to be the engine behind the CSD compliant <a href="https://wiki.ohie.org/display/SUB/Health+Worker+Registry+Community">Health Worker Registry</a> and to be incorporated in <a href="http://openhim.org/">OpenHIM</a>.


Installation
============
See the wiki https://github.com/openhie/openinfoman/wiki

To Do
=====
- [ ] Validate incoming SOAP documents before processing
- [ ] Validate incoming CSD documents before caching
- [ ] Validate interlinked entries (e.g. does the facility that a provider record points to really exist) on merged directory
- [ ] Record @sourceDirectory attribute from polled services directory in the merged directory
- [ ] Figure out how to package things better
- [ ] Figure out how to set configuration options better (e.g. database name, polled service directories, base URL) 
 
(tra-la-la)

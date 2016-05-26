OpenInfoMan
===========

OpenInfoMan is XQuery and RESTXQ based implementation of the <a href="http://wiki.ihe.net/index.php?title=Care_Services_Discovery">Care Services Discovery (CSD)</a> profile from IHE which implements the following actors and transactions:

    Info Manager : Find Matching Services (Ad-Hoc and Stored) [ITI-73]
                   Query for Updated Services Transaction [ITI-74]
    Services Directory : Query for Updated Services Transaction [ITI-74]

OpenInfoMan has been developed as part of <a href="http://ohie.org">OpenHIE</a> and is intended to be the engine behind the CSD compliant <a href="https://wiki.ohie.org/display/SUB/Health+Worker+Registry+Community">Health Worker Registry</a> and to be incorporated in <a href="http://openhim.org/">OpenHIM</a>.

CSD Schema
==========
You can find documentation for the CSD schema data mode  <a href="http://openhie.github.io/openinfoman/CSD.html">here</a> which has be generated from <a href="https://github.com/openhie/openinfoman/blob/master/resources/CSD.xsd">CSD.xsd</a>

Ubuntu Installation
===================
You can easily install on Ubuntu 14.04 and Ubuntu 14.10 using the following commands
<pre>
sudo add-apt-repository ppa:openhie/release
sudo apt-get update
sudo apt-get install openinfoman
</pre>

Once you have installed, you should be able to access OpenInfoMan at:
> http://localhost:8984/CSD

Manual Installation
===================
See the wiki https://github.com/openhie/openinfoman/wiki

OpenInfoMan Libraries
=====================
You can find additional libraries extending the core OpenInfoMan funcitonality here:
- https://github.com/openhie/openinfoman-hwr Health Worker Registry 
- https://github.com/openhie/openinfoman-dhis DHIS2
- https://github.com/openhie/openinfoman-fhir FHIR 
- https://github.com/openhie/openinfoman-rapidpro RapidPro
- https://github.com/openhie/openinfoman-opensearch OpenSearch
- https://github.com/openhie/openinfoman-hwr-nigeria Nigeria
- https://github.com/openhie/openinfoman-tz Tanzania
- https://github.com/openhie/openinfoman-ilr Inter-Linked Health Worker Registry Validation
- https://github.com/openhie/openinfoman-ldif LDIF Export
- https://github.com/openhie/openinfoman-r R Statistics Package 
- https://github.com/openhie/openinfoman-anon Anonymizer
- https://github.com/openhie/openinfoman-zim Zimbabwe
- https://github.com/openhie/openinfoman-csv Configurable Export to CSV
- https://github.com/openhie/openinfoman-whomds WHO Minimum Data Set Analysis
- https://github.com/openhie/openinfoman-zimbra  Integration with Zimbra










(tra-la-la)

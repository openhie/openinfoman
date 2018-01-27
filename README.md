# OpenInfoMan

OpenInfoMan is XQuery and RESTXQ based implementation of the <a href="http://wiki.ihe.net/index.php?title=Care_Services_Discovery">Care Services Discovery (CSD)</a> profile from IHE which implements the following actors and transactions:

    Info Manager : Find Matching Services (Ad-Hoc and Stored) [ITI-73]
                   Query for Updated Services Transaction [ITI-74]
    Services Directory : Query for Updated Services Transaction [ITI-74]

OpenInfoMan has been developed as part of <a href="http://ohie.org">OpenHIE</a> and is intended to be the engine behind the CSD compliant <a href="https://wiki.ohie.org/display/SUB/Health+Worker+Registry+Community">Health Worker Registry</a> and to be incorporated in <a href="http://openhim.org/">OpenHIM</a>.

# CSD Schema

You can find documentation for the CSD schema data mode  <a href="http://openhie.github.io/openinfoman/CSD.html">here</a> which has be generated from <a href="https://github.com/openhie/openinfoman/blob/master/resources/CSD.xsd">CSD.xsd</a>

# Ubuntu Installation

You can easily install on Ubuntu 14.04 and Ubuntu 14.10 using the following commands
```sh
sudo add-apt-repository ppa:openhie/release
sudo apt-get update
sudo apt-get install openinfoman
```

Note that the Debian packaging creates an `openinfoman` user. 

Once you have installed the package, you should be able to access OpenInfoMan at:
> http://localhost:8984/CSD

# CentOS Installation

Requirements are a Java Runtime Environment (Java 7 for the current [1.4.49] release), PHP, git, wget, and unzip. Note that php-xml is an additional requirement for CentOS.

```sh
sudo yum install -y git wget unzip java-1.7.0-openjdk php php-xml
```

The default ingress point is TCP port 8984. Ensure that port 8984 is unblocked. For example:
```sh
sudo firewall-cmd --permanent --add-port=8984/tcp
sudo firewall-cmd --reload
```

For an automated installation of the requirements in CentOS there is an Ansible playbook in [resources/scripts](https://github.com/openhie/openinfoman/tree/master/resources/scripts) for requirements (not for app installation). To use Ansible, your SSH public key should be in `.ssh/authorized_keys` and you must also create an /etc/ansible/hosts or similar with the IP address or hostname of the remote host. Ansible will require sudo privileges but these should be specified at runtime using the `--ask-become-pass` flag. For example:

```
ansible-playbook --ask-become-pass -i /usr/local/etc/ansible/hosts prep_centos.yaml
```

Once requirements are created, install OpenInfoMan using the provided script in [resources/scripts](https://github.com/openhie/openinfoman/tree/master/resources/scripts)

```sh

```

# macOS Installation

macOS does not include Java (since 10.7 and above), git, or wget. It includes unzip and PHP.

It is suggested to use [homebrew](https://brew.sh/):
```sh
brew install git wget
```

And install Java.



# Docker images

Docker builds suitable for testing are on https://hub.docker.com/r/openhie/openinfoman/ Note that the images do not use a mounted volume. This means that all data is removed when containers are destroyed. Releases are tagged with the SHA hash of the commit it is based upon in this repo.

To launch the latest Docker build:
```sh
docker run -d -p 8984:8984 docker pull openhie/openinfoman
```

See [packaging/docker](https://github.com/openhie/openinfoman/tree/master/packaging/docker)for Dockerfiles to build your own image.

# Manual Installation

See the wiki https://github.com/openhie/openinfoman/wiki

# OpenInfoMan in Production

* OpenInfoMan does not include authentication or authorization. It is meant to be run inside a private cloud/cluster and behind a proxy. Follow instructions on this [wiki manual](https://wiki.ihris.org/wiki/OIM_authentication_with_OHIM) to add authentication using OpenHIM, or this youtube video https://www.youtube.com/watch?v=bXLpNlMSZdM&feature=youtu.be or roll your own solution using another proxy with authentication.

* OpenInfoMan should be run by a user without superuser privileges. It is recommended to create a non-root and non-sudo user.

* Ensure that TCP port 8984 is open on security policy/firewall.

* Logs and data are located in `data`. Make regular backups of existing data and logs. BaseX, the underlying Java database engine, has a command for backups but similarly one may zipify the data directory.

For example:
```sh
basex -c"CREATE BACKUP provider_directory"
zip $HOME/openinfoman/data/logs-$(date +"%Y-%m-%d-%H-%M").zip $HOME/openinfoman/data/.logs
ls -la $HOME/openinfoman/data/
# move the logs and data zipfiles to a safe location, e.g.
aws s3 cp $HOME/openinfoman/data/logs-* s3://backup_bucket/logs
aws s3 cp $HOME/openinfoman/data/provider_directory-* s3://backup_bucket/data
# or
mv $HOME/openinfoman/data/logs-* ~/backup/logs
mv $HOME/openinfoman/data/provider_directory-* ~/backup/data
```

* Increase memory usage by modifying the `bin/basexhttp` shell script and uncomment
```sh
#VM=Xmx512m
```
then change to suitable values:
```sh
VM="-Xms2g -Xmx2g"
```

# OpenInfoMan Libraries

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

Stored Functions
================
The base CSD standard can be extended using stored functions.

You can find documentation on the available stored functions across the OpenInfoMan libraries <a href="http://openhie.github.io/openinfoman/stored-functions">here</a>.









(tra-la-la)

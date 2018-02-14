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

> OpenInfoMan runs on an unprivileged port. Any user can manage the processes. See notes on production deployments below.

Once requirements are created, install OpenInfoMan using the provided script in [resources/scripts](https://github.com/openhie/openinfoman/tree/master/resources/scripts)


```sh
# locally
bash resources/scripts/install_oim-1.4.49.sh
# or on a remote host
ssh user@IP_ADDR 'bash -s' < install_oim-1.4.49.sh
```

To install additional libraries:
```sh
# locally
bash resources/scripts/install_additional.sh
# or on a remote host
ssh user@IP_ADDR 'bash -s' < install_additional.sh
```

# macOS Installation

macOS does not include Java (since 10.7 and above), git, or wget. It includes unzip and PHP.

It is suggested to use [homebrew](https://brew.sh/):
```sh
brew install git wget
```

And install Java. Once requirements are created, install OpenInfoMan using the provided script in [resources/scripts](https://github.com/openhie/openinfoman/tree/master/resources/scripts)


```sh
bash resources/scripts/install_oim-1.4.49.sh
# and for additional libraries
bash resources/scripts/install_additional.sh
```

# Tests

The generic install without libraries and the libraries installations include simple tests. The tests do not cover the majority of functions, they are rather meant as a simple test for first level functionality in a help desk environment.

```sh
$ bash resources/scripts/oim_test.sh
PASS [200]: Landing page
PASS [302]: Add test document
PASS [200]: List Shared Value Sets
PASS [200]: List Stored Functions
PASS [200]: Export Stored Functions
PASS [200]: List sample dirs
PASS [302]: Load provider sample dir
PASS [200]: Get providers sample dir
PASS [302]: Reload providers dir
PASS [302]: Delete providers sample dir
PASS [302]: Remove test document
```

```sh
$ bash resources/scripts/oim_test_additional.sh
Which OpenInfoMan libraries do you wish to test?
1) All_public	     4) ILR		  7) Quit
2) All_DATIM	     5) RapidPro_and_CSV
3) DHIS		         6) HWR
#? 1
PASS [302]: DHIS - Load Sierra Leone demo as CSD
PASS [200]: DHIS - Get Sierra Leone demo as CSD
PASS [302]: DHIS - Delete Sierra Leone demo as CSD
PASS [200]: ILR - Download validate provider facility service
PASS [200]: CSV-RapidPro - Download CSV for import
PASS [200]: HWR - Get all facilities
```

# Backup and Restore

Logs and data are located in `data`. The logs are under data in the .logs folder. A one-liner can create a backup of the data in OpenInfoMan and a one-liner can restore it.

For example to backup data and logs and store them on S3:

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

For restores:

```sh
basex -c"RESTORE <filename>"
```

The backup and restore process is the same on any operating system.

# OpenInfoMan Libraries

There are additional libraries thatextend the core OpenInfoMan funcitonality:

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

To install additional libraries:

```sh
bash resources/scripts/install_additional.sh
```

There are six options. DATIM libraries require access to private repo and for SSH to be setup for git. All other options are in public repositories.

```sh
Which OpenInfoMan libraries do you wish to install?
1) All_public	     		  
2) All_DATIM	     
3) DHIS
4) ILR
5) RapidPro_and_CSV
6) HWR
7) Quit     
```


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

* Increase memory usage by modifying the `bin/basexhttp` shell script and uncomment
```sh
#VM=Xmx512m
```
then change to suitable values:
```sh
VM="-Xms2g -Xmx2g"
```

# Stored Functions

The base CSD standard can be extended using stored functions.

You can find documentation on the available stored functions across the OpenInfoMan libraries <a href="http://openhie.github.io/openinfoman/stored-functions">here</a>.

(tra-la-la)

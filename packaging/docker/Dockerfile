FROM ubuntu:14.04

RUN apt-get -qq update && \
    apt-get -y install software-properties-common \
    python-software-properties inotify-tools debconf-utils && \
    apt-get -y install git wget unzip default-jre openjdk-7-jre php5

WORKDIR /root

RUN wget --quiet http://files.basex.org/releases/8.5.3/BaseX853.zip
RUN unzip BaseX853.zip
RUN mkdir openinfoman
RUN cp -R basex/* openinfoman/
RUN cp basex/.basexhome openinfoman/

RUN mkdir openinfoman/repo-src
RUN git clone --single-branch -b connectathonTZ https://github.com/openhie/openinfoman openinfomangh
RUN cp openinfomangh/repo/* openinfoman/repo-src/
RUN cp -R openinfomangh/resources openinfoman/
RUN cp ~/openinfomangh/webapp/*xqm ~/openinfoman/webapp
RUN mkdir -p ~/openinfoman/webapp/static
RUN cp -R ~/openinfomangh/webapp/static/* ~/openinfoman/webapp/static
RUN ln -s ~/openinfoman/bin/basex /usr/local/bin

RUN basex -Vc "CREATE DATABASE provider_directory"

RUN echo "module namespace csd_webconf = 'https://github.com/openhie/openinfoman/csd_webconf';\n\
    declare variable \$csd_webconf:db :=  'provider_directory';\n\
    declare variable \$csd_webconf:baseurl :=  '';\n\
    declare variable \$csd_webconf:remote_services := ();\n\
    " > $HOME/openinfoman/repo-src/generated_openinfoman_webconfig.xqm

RUN basex -Vc "REPO INSTALL https://files.basex.org/modules/expath/functx-1.0.xar"

WORKDIR /root/openinfoman/repo-src
# Change shell to bash to interpret array syntax
SHELL ["/bin/bash", "-c"]

RUN declare -a arr=("generated_openinfoman_webconfig.xqm" "csd_webapp_ui.xqm" "csd_base_library.xqm" "csd_base_library_updating.xqm"   "csd_base_stored_queries.xqm"  "csd_document_manager.xqm"  "csd_load_sample_directories.xqm"  "csd_query_updated_services.xqm"  "csd_poll_service_directories.xqm"  "csd_local_services_cache.xqm"  "csd_merge_cached_services.xqm"  "csr_processor.xqm"  "svs_load_shared_value_sets.xqm"  "async_fake.xqm"); \
    for i in "${arr[@]}"; do basex -Vc "repo install $i"; done
RUN basex -Vc "RUN $HOME/openinfoman/resources/scripts/init_db.xq"

WORKDIR /root/openinfoman
RUN declare -a arr=(resources/stored*definitions/*xml);\
    for i in "${arr[@]}"; do resources/scripts/install_stored_function.php $i; done

WORKDIR /root/openinfoman/resources/shared_value_sets

RUN declare -a arr=(*);\
    for i in "${arr[@]}"; do basex -q"import module namespace svs_lsvs = 'https://github.com/openhie/openinfoman/svs_lsvs';' (svs_lsvs:load($i))'" ; done

### openinfoman-csv
WORKDIR /root
RUN git clone https://github.com/openhie/openinfoman-csv
WORKDIR /root/openinfoman-csv/repo
RUN basex -Vc "REPO INSTALL openinfoman_csv_adapter.xqm"
# this may not be needed
RUN cp ~/openinfoman-csv/webapp/*xqm ~/openinfoman/webapp

### openinfoman-rapidpro
WORKDIR /root
RUN git clone https://github.com/openhie/openinfoman-rapidpro
WORKDIR /root/openinfoman
RUN declare -a arr=("$HOME/openinfoman-rapidpro/resources/stored*definitions/*xml");\
    for i in "${arr[@]}"; do resources/scripts/install_stored_function.php $i; done
RUN cp ~/openinfoman-rapidpro/webapp/openinfoman_rapidpro_bindings.xqm ~/openinfoman/webapp

### openinfoman-ilr
WORKDIR /root
RUN git clone https://github.com/openhie/openinfoman-ilr
WORKDIR /root/openinfoman
RUN declare -a arr=("$HOME/openinfoman-ilr/resources/stored*definitions/*xml");\
    for i in "${arr[@]}"; do resources/scripts/install_stored_function.php $i; done

### openinfoman-hwr
WORKDIR /root
RUN git clone https://github.com/openhie/openinfoman-hwr
WORKDIR /root/openinfoman
RUN declare -a arr=("$HOME/openinfoman-hwr/resources/stored*definitions/*xml");\
    for i in "${arr[@]}"; do resources/scripts/install_stored_function.php $i; done

### openinfoman-dhis
WORKDIR /root
RUN git clone https://github.com/openhie/openinfoman-dhis
RUN cp openinfoman-dhis/repo/* openinfoman/repo-src/
WORKDIR /root/openinfoman/repo-src
RUN declare -a arr=("dxf2csd.xqm" "dxf_1_0.xqm" "util.xqm");\
    for i in "${arr[@]}"; do basex -Vc "repo install $i"; done
WORKDIR /root/openinfoman
RUN declare -a arr=("$HOME/openinfoman-dhis/resources/stored*definitions/*xml");\
    for i in "${arr[@]}"; do resources/scripts/install_stored_function.php $i; done
RUN cp ~/openinfoman-dhis/webapp/openinfoman_dhis2_bindings.xqm ~/openinfoman/webapp
RUN cp -R ~/openinfoman-dhis/resources/service_directories/* ~/openinfoman/resources/service_directories/

# Must switch back to this dir or paths will fail
WORKDIR /root/openinfoman/bin

EXPOSE 8984 8985 1984

SHELL ["/bin/sh", "-c"]

ENTRYPOINT ["/root/openinfoman/bin/basexhttp"]

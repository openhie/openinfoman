#!/bin/bash
#set -ex
set -e

printf "\n\e[32mInstalling OpenInfoMan\033[0;37m\n"

# cleanup from last install
cd $HOME
$HOME/openinfoman/bin/basexhttp stop || true
rm -rf BaseX8* || true
rm -rf basex/ || true
# remove the cloned repos
rm -rf openinfomangh || true

BASEX=$HOME/openinfoman/bin/basex

wget http://files.basex.org/releases/8.5.3/BaseX853.zip
# wget http://files.basex.org/releases/8.6.7/BaseX867.zip
unzip BaseX853.zip
mkdir -p $HOME/openinfoman
cp -R $HOME/basex/* $HOME/openinfoman/
cp $HOME/basex/.basexhome $HOME/openinfoman/

# increase memory to 3GB:
sed -i '' 's/-Xmx512m/-Xms3g -Xmx3g/' $HOME/openinfoman/bin/basexhttp

if  [ -d $HOME/openinfoman/data/provider_directory ]
then
  printf "\n\e[32mBaseX Database provider_directory exists\033[0;37m\n"
  # backup data and logs for safety
  mkdir -p $HOME/backup/data
  mkdir -p $HOME/backup/logs
  # use official basex command for backups in order to be robust to jobs in the queue
  $BASEX -Vc 'create backup provider_directory'
  mv $HOME/openinfoman/data/provider_directory-* $HOME/backup/data
  # if there's a previous install but was never run there will be 'data' but not logs'
  zip $HOME/openinfoman/data/logs-$(date +"%Y-%m-%d-%H-%M").zip $HOME/openinfoman/data/.logs || true
  mv $HOME/openinfoman/data/logs-* $HOME/backup/logs || true
else
  printf "\n\e[32mBaseX Database provider_directory does not exist\033[0;37m\n"
  $BASEX -Vc 'create database provider_directory'
fi

git clone https://github.com/openhie/openinfoman openinfomangh
# cd $HOME/openinfomangh
# git checkout tags/1.4.61
cd $HOME/openinfoman

mkdir -p $HOME/openinfoman/repo-src
cp $HOME/openinfomangh/repo/* $HOME/openinfoman/repo-src/
cp -R $HOME/openinfomangh/resources $HOME/openinfoman/

cp $HOME/openinfomangh/webapp/*xqm $HOME/openinfoman/webapp
mkdir -p $HOME/openinfoman/webapp/static
cp -R $HOME/openinfomangh/webapp/static/* $HOME/openinfoman/webapp/static

printf "module namespace csd_webconf = 'https://github.com/openhie/openinfoman/csd_webconf';
declare variable \$csd_webconf:db :=  'provider_directory';
declare variable \$csd_webconf:baseurl :=  '';
declare variable \$csd_webconf:remote_services := ();
" > $HOME/openinfoman/repo-src/generated_openinfoman_webconfig.xqm

$BASEX -Vc "REPO INSTALL http://files.basex.org/modules/expath/functx-1.0.xar"

cd $HOME/openinfoman/repo-src
mv csd_webapp_config.xqm csd_webapp_config.xqm.orig
REPOS=("generated_openinfoman_webconfig.xqm" "csd_webapp_ui.xqm" "csd_base_library.xqm" "csd_base_library_updating.xqm" "csd_base_stored_queries.xqm" "csd_document_manager.xqm" "csd_load_sample_directories.xqm" "csd_query_updated_services.xqm" "csd_poll_service_directories.xqm" "csd_local_services_cache.xqm" "csd_merge_cached_services.xqm" "csr_processor.xqm" "svs_load_shared_value_sets.xqm" "async_fake.xqm")
for REPO in ${REPOS[@]}
do
   INST="REPO INSTALL $REPO"
   $BASEX -Vc "${INST}"
done

$BASEX -Vc "RUN $HOME/openinfoman/resources/scripts/init_db.xq"

cd $HOME/openinfoman
# SFS=resources/stored*definitions/*xml <-- this is not working correctly
SFS=("stored_query_definitions/facility_search.xml" "stored_query_definitions/adhoc_search.xml" "stored_query_definitions/service_search.xml" "stored_query_definitions/organization_search.xml" "stored_query_definitions/provider_search.xml" "stored_query_definitions/modtimes.xml" "stored_updating_query_definitions/mark_not_duplicate.xml" "stored_updating_query_definitions/service_create.xml" "stored_updating_query_definitions/mark_duplicate.xml" "stored_updating_query_definitions/simple_merge.xml" "stored_updating_query_definitions/mark_potential_duplicate.xml" "stored_updating_query_definitions/delete_potential_duplicate.xml" "stored_updating_query_definitions/organization_create.xml" "stored_updating_query_definitions/provider_create.xml" "stored_updating_query_definitions/facility_create.xml" "stored_updating_query_definitions/delete_duplicate.xml" "stored_updating_query_definitions/merge_by_identifier.xml" "stored_updating_query_definitions/extract_hierarchy.xml")

for SF in ${SFS[@]}
do
  resources/scripts/install_stored_function.php resources/$SF
done

SVS=$HOME/openinfoman/resources/shared_value_sets/*
for SV in ${SVS[@]}
do
  $BASEX -q"import module namespace svs_lsvs = 'https://github.com/openhie/openinfoman/svs_lsvs';' (svs_lsvs:load($SV))'"
done

# cd $HOME/openinfoman/bin && nohup ./basexhttp > foo.out 2> foo.err < /dev/null &
cd $HOME/openinfoman/bin && nohup ./basexhttp &

printf "\n\e[32mOpenInfoMan successfully installed and started!\033[0;37m\n"

exit
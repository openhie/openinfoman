#!/bin/bash
#set -ex
set -e

# cleanup from last install
cd $HOME
$HOME/openinfoman/bin/basexhttp stop || true
rm -rf BaseX853* || true
rm -rf basex/ || true
# remove the cloned repos
rm -rf openinfomangh || true

BASEX=$HOME/openinfoman/bin/basex

wget http://files.basex.org/releases/8.5.3/BaseX853.zip
unzip BaseX853.zip
mkdir -p $HOME/openinfoman
cp -R $HOME/basex/* $HOME/openinfoman/
cp $HOME/basex/.basexhome $HOME/openinfoman/

if  [ -d $HOME/openinfoman/data/provider_directory ]
then
  echo "BaseX Database provider_directory exists\n"
  # backup data and logs for safety
  mkdir -p $HOME/backup/data
  mkdir -p $HOME/backup/logs
  zip $HOME/openinfoman/data/provider_directory-$(date +"%Y-%m-%d-%H-%M").zip $HOME/openinfoman/data/provider_directory
  mv $HOME/openinfoman/data/provider_directory-* $HOME/backup/data
  # if there's a previous install but was never run there will be 'data' but not logs'
  zip $HOME/openinfoman/data/logs-$(date +"%Y-%m-%d-%H-%M").zip $HOME/openinfoman/data/.logs || true
  mv $HOME/openinfoman/data/logs-* $HOME/backup/logs || true
else
  echo "BaseX Database provider_directory does not exist\n"
  $BASEX -Vc 'create database provider_directory'
fi

git clone https://github.com/openhie/openinfoman openinfomangh
# checkout 1.4.49
cd $HOME/openinfomangh
git checkout tags/1.4.49
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
SFS=resources/stored*definitions/*xml
for SF in ${SFS[@]}
do
  resources/scripts/install_stored_function.php $SF
done

SVS=$HOME/openinfoman/resources/shared_value_sets/*
for SV in ${SVS[@]}
do
  $BASEX -q"import module namespace svs_lsvs = 'https://github.com/openhie/openinfoman/svs_lsvs';' (svs_lsvs:load($SV))'"
done

cd $HOME/openinfoman/bin && nohup ./basexhttp > foo.out 2> foo.err < /dev/null &

printf "\e[32mOpenInfoMan successfully installed and started!\n"

exit
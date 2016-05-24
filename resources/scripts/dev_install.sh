#!/bin/sh
set -x
set -e

REPOS=("csd_webapp_ui.xqm" "csd_base_library.xqm" "csd_base_library_updating.xqm"   "csd_base_stored_queries.xqm"  "csd_document_manager.xqm"  "csd_load_sample_directories.xqm"  "csd_query_updated_services.xqm"  "csd_poll_service_directories.xqm"  "csd_local_services_cache.xqm"  "csd_merge_cached_services.xqm"  "csr_processor.xqm"  "svs_load_shared_value_sets.xqm"  )



OI=/var/lib/openinfoman
BASEX=$OI/bin/basex
#directory this script is in
DIRNAME=`dirname $0`
DIR="`cd $DIRNAME/../..; pwd`"

touch $OI/.basexhome


set +e
$BASEX -Vc "list provider_directory" > /dev/null
if [ $? -eq 0 ]; then
    echo "BaseX Database provider_directory exists\n"
else
    echo "BaseX Database provider_directory does not exist\n"
    $BASEX -Vc 'create database provider_directory'
fi
set -e

$BASEX -Vc "RUN $DIR/resources/scripts/init_db.xq"


mkdir -p $OI/repo-src
mkdir -p $OI/resources/scripts/
mkdir -p $OI/resources/stored_query_definitions
mkdir -p $OI/resources/stored_updating_query_definitions
mkdir -p $OI/resources/services_directories
mkdir -p $OI/resources/shared_value_sets


$BASEX -Vc "REPO INSTALL http://files.basex.org/modules/expath/functx-1.0.xar"

cd $OI/webapp  && ln -sf $DIR/webapp/*xqm .
cd $OI/webapp/static  && cp -R $DIR/webapp/static/* ./


SCRIPTS=$DIR/resources/scripts/*

for SCRIPT in ${SCRIPTS[@]}
do
    cp $SCRIPT /var/lib/openinfoman/resources/scripts
done

cd $OI
for REPO in ${REPOS[@]}
do
   INST="REPO INSTALL $DIR/repo/$REPO"
   $BASEX -Vc "${INST}"
done


SFS=$DIR/resources/stored*definitions/*xml

cd $OI
for SF in ${SFS[@]}
do
  $OI/resources/scripts/install_stored_function.php $SF
  if [[ $? != 0 ]]; then exit 1; fi
done


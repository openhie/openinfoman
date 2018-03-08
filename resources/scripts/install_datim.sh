#!/bin/bash
# set -ex
set -e

cd $HOME
# $HOME/openinfoman/basex/bin/basexhttp stop || true

BASEX=$HOME/openinfoman/bin/basex

# openinfoman-dhis
function dhis () {
  printf "\n\e[32mInstalling openinfoman-dhis...\033[0;37m\n"
  cd $HOME
  rm -rf openinfoman-dhis || true
  git clone https://github.com/openhie/openinfoman-dhis
  cp openinfoman-dhis/repo/* openinfoman/repo-src/
  cd $HOME/openinfoman/repo-src
  declare -a arr=("dxf2csd.xqm" "dxf_1_0.xqm" "util.xqm");\
  for i in "${arr[@]}"; do $BASEX -Vc "repo install $i"; done
  SFS=$HOME/openinfoman-dhis/resources/stored*definitions/*xml
  cd $HOME/openinfoman
  for SF in ${SFS[@]}
  do
    resources/scripts/install_stored_function.php $SF
  done
  cp $HOME/openinfoman-dhis/webapp/openinfoman_dhis2_bindings.xqm $HOME/openinfoman/webapp
  cp -R $HOME/openinfoman-dhis/resources/service_directories/* $HOME/openinfoman/resources/service_directories/
}

# openinfoman-datim: requires openinfoman-dhis
function datim () {
  printf "\n\e[32mInstalling openinfoman-datim...\n"
  printf "\n\e[32mExit now if you have not configured access to the openinfoman-datim private repo\033[0;37m\n"
  sleep 5
  cd $HOME
  rm -rf openinfoman-datim || true
  git clone git@github.com:pepfar-datim/openinfoman-datim.git
  cp openinfoman-datim/repo/* openinfoman/repo-src/
  cd $HOME/openinfoman/repo-src
  declare -a arr=("datim-uuid.xqm" "datim.xqm");\
  for i in "${arr[@]}"; do $BASEX -Vc "repo install $i"; done
  SFS=$HOME/openinfoman-datim/resources/stored*definitions/*xml
  cd $HOME/openinfoman
  for SF in ${SFS[@]}
  do
    resources/scripts/install_stored_function.php $SF
  done
  cp $HOME/openinfoman-datim/webapp/* $HOME/openinfoman/webapp
  cp -R $HOME/openinfoman-datim/resources/service_directories/* $HOME/openinfoman/resources/service_directories/
}

dhis; datim; printf "\n\e[32mCompleted!\n";

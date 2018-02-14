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

# openinfoman-ilr
function ilr () {
  printf "\n\e[32mInstalling openinfoman-ilr\033[0;37m\n"
  cd $HOME
  rm -rf openinfoman-ilr || true
  git clone https://github.com/openhie/openinfoman-ilr
  SFS=$HOME/openinfoman-ilr/resources/stored*definitions/*xml
  cd $HOME/openinfoman
  for SF in ${SFS[@]}
  do
    resources/scripts/install_stored_function.php $SF
  done
}

# openinfoman-csv
function csv () {
  printf "\n\e[32mInstalling openinfoman-csv\033[0;37m\n"
  cd $HOME
  rm -rf openinfoman-csv || true
  git clone https://github.com/openhie/openinfoman-csv
  cd ~/openinfoman-csv/repo
  $BASEX -Vc "REPO INSTALL openinfoman_csv_adapter.xqm"
  # this may not be needed
  cp ~/openinfoman-csv/webapp/*xqm ~/openinfoman/webapp
}

# openinfoman-rapidpro: requires openinfoman-csv
function rapidpro () {
  printf "\n\e[32mInstalling openinfoman-rapidpro\033[0;37m\n"
  cd $HOME
  rm -rf openinfoman-rapidpro || true
  git clone https://github.com/openhie/openinfoman-rapidpro
  SFS=$HOME/openinfoman-rapidpro/resources/stored*definitions/*xml
  cd $HOME/openinfoman
  for SF in ${SFS[@]}
  do
    resources/scripts/install_stored_function.php $SF
  done
  cp ~/openinfoman-rapidpro/webapp/openinfoman_rapidpro_bindings.xqm ~/openinfoman/webapp
}

# openinfoman-hwr
function hwr () {
  printf "\n\e[32mInstalling openinfoman-hwr\033[0;37m\n"
  cd $HOME
  rm -rf openinfoman-hwr || true
  git clone https://github.com/openhie/openinfoman-hwr
  SFS=$HOME/openinfoman-hwr/resources/stored*definitions/*xml
  cd $HOME/openinfoman
  for SF in ${SFS[@]}
  do
    resources/scripts/install_stored_function.php $SF
  done
}


# options: 
# dhis
# datim: req dhis
# ilr
# csv
# rapidpro: req csv
# hwr

echo "Which OpenInfoMan libraries do you wish to install?"
select yn in "All_public" "All_DATIM" "DHIS" "ILR" "RapidPro_and_CSV" "HWR" "Quit"; do
  case $yn in
      All_public ) dhis; ilr; csv; rapidpro; hwr; printf "\n\e[32mCompleted!\n"; break;;
      All_DATIM) dhis; datim; printf "\n\e[32mCompleted!\n"; break;;
      DHIS) dhis; printf "\n\e[32mCompleted!\n"; break;;
      ILR) ilr; printf "\n\e[32mCompleted!\n"; break;;
      RapidPro_and_CSV) csv; rapidpro; printf "\n\e[32mCompleted!\n"; break;;
      HWR) hwr; printf "\n\e[32mCompleted!\n"; break;;
      Quit ) printf "\n\e[32mQuit!\n"; exit;;
  esac
done

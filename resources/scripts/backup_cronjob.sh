#!/bin/bash
#set -ex
set -e

cd $HOME
BASEX=$HOME/openinfoman/bin/basex

if  [ -d $HOME/openinfoman/data/provider_directory ]
then
  printf "\n\e[32mBaseX Database exists\033[0;37m\n"

  mkdir -p $HOME/backup/data
  mkdir -p $HOME/backup/logs

  $BASEX -Vc 'create backup provider_directory'
  mv $HOME/openinfoman/data/provider_directory-* $HOME/backup/data
  printf "\n\e[32mCreated backup of data\033[0;37m\n"
  # if there's a previous install but was never run there will be 'data' but not logs'
  zip $HOME/openinfoman/data/logs-$(date +"%Y-%m-%d-%H-%M").zip $HOME/openinfoman/data/.logs || true
  mv $HOME/openinfoman/data/logs-* $HOME/backup/logs || true
  printf "\n\e[32mCreated backup of logs\033[0;37m\n"

else
  printf "\n\e[32mBaseX Database to backup does not exist\033[0;37m\n"
fi

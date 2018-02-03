#!/bin/bash
# set -ex
set -e

cd $HOME
# $HOME/openinfoman/basex/bin/basexhttp stop || true

BASEX=$HOME/openinfoman/bin/basex

function dhis () {
    res=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8984/CSD/initSampleDirectory/directory/sierra_leone_demo_metadata_as_csd/load)
    if [ "$res" == "200" ] || [ "$res" == "302" ]
    then
        printf "\033[32mPASS [$res]: DHIS - Load Sierra Leone demo as CSD\n"
    else
        printf "\033[31mFAIL [$res]: DHIS - Load Sierra Leone demo as CSD\n"
    fi

    res=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8984/CSD/initSampleDirectory/directory/sierra_leone_demo_metadata_as_csd/get)
    if [ "$res" == "200" ] || [ "$res" == "302" ]
    then
        printf "\033[32mPASS [$res]: DHIS - Get Sierra Leone demo as CSD\n"
    else
        printf "\033[31mFAIL [$res]: DHIS - Get Sierra Leone demo as CSD\n"
    fi

    res=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8984/CSD/deleteDirectory/sierra_leone_demo_metadata_as_csd)
    if [ "$res" == "200" ] || [ "$res" == "302" ]
    then
        printf "\033[32mPASS [$res]: DHIS - Delete Sierra Leone demo as CSD\n"
    else
        printf "\033[31mFAIL [$res]: DHIS - Delete Sierra Leone demo as CSD\n"
    fi
}

function datim () {
    res=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8984/CSD/initSampleDirectory/directory/datim-test-mechanisms/load)
    if [ "$res" == "200" ] || [ "$res" == "302" ]
    then
        printf "\033[32mPASS [$res]: DATIM - Load datim-mechanism-test\n"
    else
        printf "\033[31mFAIL [$res]: DATIM - Load datim-mechanism-test\n"
    fi

    res=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8984/CSD/initSampleDirectory/directory/datim-test-mechanisms/get)
    if [ "$res" == "200" ] || [ "$res" == "302" ]
    then
        printf "\033[32mPASS [$res]: DATIM - Get datim-mechanism-test\n"
    else
        printf "\033[31mFAIL [$res]: DATIM - Get datim-mechanism-test\n"
    fi

    res=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8984/CSD/deleteDirectory/datim-test-mechanisms)
    if [ "$res" == "200" ] || [ "$res" == "302" ]
    then
        printf "\033[32mPASS [$res]: DATIM - Delete datim-mechanism-test\n"
    else
        printf "\033[31mFAIL [$res]: DATIM - Delete datim-mechanism-test\n"
    fi
}

function ilr () {
    res=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8984/CSD/storedFunctions/download/urn:openhie.org:openinfoman-ilr:validate_provider_facility_service)
    if [ "$res" == "200" ] || [ "$res" == "302" ]
    then
        printf "\033[32mPASS [$res]: ILR - Download validate provider facility service\n"
    else
        printf "\033[31mFAIL [$res]: ILR - Download validate provider facility service\n"
    fi
}

function csv-rapidpro () {
    res=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8984/CSD/storedFunctions/download/urn:openhie.org:openinfoman-rapidpro:get_csv_for_import)
    if [ "$res" == "200" ] || [ "$res" == "302" ]
    then
        printf "\033[32mPASS [$res]: CSV-RapidPro - Download CSV for import\n"
    else
        printf "\033[31mFAIL [$res]: CSV-RapidPro - Download CSV for import\n"
    fi
}

function hwr () {
    res=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8984/CSD/storedFunctions/download/urn:openhie.org:openinfoman-hwr:stored-function:facility_get_all)
    if [ "$res" == "200" ] || [ "$res" == "302" ]
    then
        printf "\033[32mPASS [$res]: HWR - Get all facilities\n"
    else
        printf "\033[31mFAIL [$res]: HWR - Get all facilities\n"
    fi
}

# rapidpro and csv are combined
echo "Which OpenInfoMan libraries do you wish to test?"
select yn in "All_public" "All_DATIM" "DHIS" "ILR" "RapidPro_and_CSV" "HWR" "Quit"; do
  case $yn in
      All_public ) dhis; ilr; csv-rapidpro; hwr; printf "\n\e[32mCompleted!\n"; break;;
      All_DATIM) dhis; datim; printf "\n\e[32mCompleted!\n"; break;;
      DHIS) dhis; printf "\n\e[32mCompleted!\n"; break;;
      ILR) ilr; printf "\n\e[32mCompleted!\n"; break;;
      RapidPro_and_CSV) csv-rapidpro; printf "\n\e[32mCompleted!\n"; break;;
      HWR) hwr; printf "\n\e[32mCompleted!\n"; break;;
      Quit ) printf "\n\e[32mQuit!\n"; exit;;
  esac
done

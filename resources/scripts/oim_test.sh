#!/usr/bin/env bash

# the installation creates a database called `provider_directory`. Inside `provider_directory` will be created actual directories. 

cd $HOME/openinfoman

BASEX=$HOME/openinfoman/bin/basex

# GET request to main site
res=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8984/CSD)
if [ "$res" == "200" ]
then
    printf "\033[32mPASS [$res]: Landing page\n"
else
    printf "\033[31mFAIL [$res]: Landing page\n"
fi

# create test doc
res=$(curl --write-out %{http_code} --silent -X POST -F 'directory=test' http://localhost:8984/CSD/createDirectory)
if [ "$res" == "200" ] || [ "$res" == "302" ]
then
    printf "\033[32mPASS [$res]: Add test document\n"
else
    printf "\033[31mFAIL [$res]: Add test document\n"
fi

# list SVS
res=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8984/CSD/SVS/initSharedValueSet)
if [ "$res" == "200" ] || [ "$res" == "302" ]
then
    printf "\033[32mPASS [$res]: List Shared Value Sets\n"
else
    printf "\033[31mFAIL [$res]: List Shared Value Sets\n"
fi

# list stored functions
res=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8984/CSD/storedFunctions)
if [ "$res" == "200" ] || [ "$res" == "302" ]
then
    printf "\033[32mPASS [$res]: List Stored Functions\n"
else
    printf "\033[31mFAIL [$res]: List Stored Functions\n"
fi

# export stored functions
res=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8984/CSD/storedFunctions/export_funcs)
if [ "$res" == "200" ] || [ "$res" == "302" ]
then
    printf "\033[32mPASS [$res]: Export Stored Functions\n"
else
    printf "\033[31mFAIL [$res]: Export Stored Functions\n"
fi

# list possible inits for sample dirs
res=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8984/CSD/initSampleDirectory)
if [ "$res" == "200" ] || [ "$res" == "302" ]
then
    printf "\033[32mPASS [$res]: List sample dirs\n"
else
    printf "\033[31mFAIL [$res]: List sample dirs\n"
fi

# load provider sample dir
res=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8984/CSD/initSampleDirectory/directory/providers/load)
if [ "$res" == "200" ] || [ "$res" == "302" ]
then
    printf "\033[32mPASS [$res]: Load provider sample dir\n"
else
    printf "\033[31mFAIL [$res]: Load provider sample dir\n"
fi

# get providers sample
res=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8984/CSD/initSampleDirectory/directory/providers/get)
if [ "$res" == "200" ] || [ "$res" == "302" ]
then
    printf "\033[32mPASS [$res]: Get providers sample dir\n"
else
    printf "\033[31mFAIL [$res]: Get providers sample dir\n"
fi

# get providers sample
res=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8984/CSD/initSampleDirectory/directory/providers/reload)
if [ "$res" == "200" ] || [ "$res" == "302" ]
then
    printf "\033[32mPASS [$res]: Reload providers dir\n"
else
    printf "\033[31mFAIL [$res]: Reload providers dir\n"
fi

# delete providers sample dir
res=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8984/CSD/deleteDirectory/providers)
if [ "$res" == "200" ] || [ "$res" == "302" ]
then
    printf "\033[32mPASS [$res]: Delete providers sample dir\n"
else
    printf "\033[31mFAIL [$res]: Delete providers sample dir\n"
fi

# delete doc test
res=$(curl --write-out %{http_code} --silent -X GET http://localhost:8984/CSD/deleteDirectory/test)
if [ "$res" == "200" ] || [ "$res" == "302" ]
then
    printf "\033[32mPASS [$res]: Remove test document\n"
else
    printf "\033[31mFAIL [$res]: Remove test document\n"
fi



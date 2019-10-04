#!/usr/bin/env bash

mkdir -p /tmp/synapse-downloader/test-files/
mkdir -p /tmp/synapse-downloader/downloadedfiles/
NFILES=5 # number of files to create
NDIR=5 # number of directories to create $NFILES in
MB=25 # MB file size of each file
CACHE_DIR=/home/kdaily/.synapseCache

for METHOD in new old sync ; do
    echo "#####################" ;
    echo "Using ${METHOD}" ;
    echo "#####################";

    echo "#####################" ;
    echo "Setup project, folders, and files." ;
    echo "#####################" ;

    PROJID=$(synapse create --name 'Test Synapse Downloader' Project | grep "Create" | sed "s/.*\(syn[0-9]*\).*/\1/");

    for FOLDERNUM in $(seq 1 ${NDIR}) ; do
        FOLDERNAME="Folder ${FOLDERNUM}";
        FOLDERID=$(synapse create --name "${FOLDERNAME}" Folder --parentId ${PROJID} | grep "Create" | sed "s/.*\(syn[0-9]*\).*/\1/");

        seq 1 ${NFILES} | xargs -I {} -n 1 dd status=none if=/dev/urandom of=/tmp/synapse-downloader/test-files/file{}.txt bs=1048576 count=${MB} ;

        seq 1 ${NFILES} | xargs -I {} -n 1 -P 4 synapse store --parentId ${FOLDERID} /tmp/synapse-downloader/test-files/file{}.txt > /dev/null 2>&1 ;

        rm /tmp/synapse-downloader/test-files/file*.txt ;
    done

    echo "#####################" ;
    echo "Clear cache" ;
    echo "#####################" ;

    rm -rf ${CACHE_DIR}* ; # Clear the Synapse cache so that it's not used

    echo "#####################" ;
    echo "Download" ;
    echo "#####################" ;
    
    synapse-downloader ${PROJID} -s ${METHOD} /tmp/synapse-downloader/downloadedfiles/ ;

    echo "#####################" ;
    echo "Cleanup" ;
    echo "#####################" ;

    rm -rf /tmp/synapse-downloader/downloadedfiles/* ;
    rm -rf ${CACHE_DIR}* ; # Clear the Synapse cache so that it's not used
    synapse delete ${PROJID} ;

done


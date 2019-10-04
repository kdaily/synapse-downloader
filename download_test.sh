#!/usr/bin/env bash

mkdir -p /tmp/synapse-downloader/test-files/
mkdir -p /tmp/synapse-downloader/downloadedfiles/
NFILES=5 # number of files to create
MB=50 # MB file size of each file

PROJID=$(synapse create --name 'Test Synapse Downloader' Project | grep "Create" | sed "s/.*\(syn[0-9]*\).*/\1/");

echo "#####################" ;
echo "Creating files" ;
echo "#####################" ;

seq 1 ${NFILES} | xargs -I {} -n 1 dd status=none if=/dev/urandom of=/tmp/synapse-downloader/test-files/file{}.txt bs=1048576 count=${MB} ;

echo "#####################" ;
echo "Storing to Synapse" ;
echo "#####################" ;

seq 1 ${NFILES} | xargs -I {} -n 1 -P 4 synapse store --parentId ${PROJID} /tmp/synapse-downloader/test-files/file{}.txt 2> /dev/null;

for METHOD in new old sync ; do

    echo "#####################" ;
    echo "Using ${METHOD}" ;
    echo "#####################";

    echo "#####################" ;
    echo "Clear cache" ;
    echo "#####################" ;

    rm -rf /tmp/synapseCache/* ; # Clear the Synapse cache so that it's not used
    rm /tmp/synapse-downloader/test-files/file*.txt ;

    echo "#####################" ;
    echo "Download" ;
    echo "#####################" ;
    
    synapse-downloader ${PROJID} -s ${METHOD} /tmp/synapse-downloader/downloadedfiles/ ;

    echo "#####################" ;
    echo "Cleanup" ;
    echo "#####################" ;

    rm /tmp/synapse-downloader/downloadedfiles/file*.txt ;
    rm -rf /tmp/synapseCache/* ;
done

synapse delete ${PROJID} ;

#!/bin/sh


URL=$1
if [ -z $URL ]; then
    echo "Provide a url to download"
    exit 1
fi

domain=$(echo $URL | awk -F[/:] '{print $4}')

wget \
     --recursive \
     --no-clobber \
     --page-requisites \
     --html-extension \
     --convert-links \
     --restrict-file-names=windows \
     --domains $domain \
     --no-parent \
     $URL

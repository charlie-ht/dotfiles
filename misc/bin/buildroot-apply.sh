#!/bin/bash

#  buildroot-apply.sh X
#
#  This will apply all patches in series number X to the CWD.

REV=$1
if [[ -z $REV ]] ; then
    echo "provide a revision"
    exit 1
fi

MBOX_URL="https://patchwork.ozlabs.org/series/$REV/mbox/"
wget -qO- $MBOX_URL | git am -3


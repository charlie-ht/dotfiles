#!/bin/bash

#
# I use this script to synchronize a chroot between my powerful build
# machine and my meager laptop when I need to travel, and when I return.
#
# On the laptop, I then pray there's a compute resource I can either
# copy the source assets to, build, and copy build assets back, or
# an icecream cluster I can hook into.
#

LOCAL_CHROOT=$1
REMOTE_CHROOT=$2

if [[ -z $LOCAL_CHROOT || -z $REMOTE_CHROOT ]]; then
    echo Usage: $0 LOCAL_CHROOT REMOTE_CHROOT
    echo E.g $0 $HOME/chroots/webkit charles@elter:chroots/
    exit 1
fi

rsync --verbose --archive --one-file-system \
      --xattrs --hard-links --numeric-ids --sparse --acls \
      $LOCAL_CHROOT $REMOTE_CHROOT

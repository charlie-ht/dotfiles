#!/bin/bash

isMounted    () { findmnt -rno SOURCE,TARGET "$1" >/dev/null;} #path or device
isDevMounted () { findmnt -rno SOURCE        "$1" >/dev/null;} #device only
isPathMounted() { findmnt -rno        TARGET "$1" >/dev/null;} #path   only

if ! [ $(id -u) = 0 ]; then
   echo "need root"
   exit 1
fi

DEV=/dev/mmcblk0
PART1=/dev/mmcblk0p1
PART2=/dev/mmcblk0p2

if isDevMounted $PART1 ; then
    umount $PART1
fi
    
if isDevMounted $PART2 ; then
    umount $PART2
fi

OUTPUT_DIR=${1:-$HOME/buildroots/rpi3_fdo_32}

read -p "Flashing  $OUTPUT_DIR/images/sdcard.img  to $DEV ; ok?" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    dd if=$OUTPUT_DIR/images/sdcard.img of=$DEV bs=4M conv=fsync
fi


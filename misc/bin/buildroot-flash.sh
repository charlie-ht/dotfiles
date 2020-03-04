#!/bin/bash

isMounted    () { findmnt -rno SOURCE,TARGET "$1" >/dev/null;} #path or device
isDevMounted () { findmnt -rno SOURCE        "$1" >/dev/null;} #device only
isPathMounted() { findmnt -rno        TARGET "$1" >/dev/null;} #path   only


if lsblk | grep -q mmcblk ; then
    DEV=/dev/mmcblk0
    PART1=/dev/mmcblk0p1
    PART2=/dev/mmcblk0p2
elif lsblk | grep -q sda ; then
    DEV=/dev/sda
    PART1=/dev/sda1
    PART2=/dev/sda2
else
    echo "Unknown media"
    exit 1
fi

if isDevMounted $PART1 ; then
    umount $PART1
fi
    
if isDevMounted $PART2 ; then
    umount $PART2
fi

OUTPUT_DIR=${1:-$HOME/igalia/buildroot/output}

read -p "Flashing  $OUTPUT_DIR/images/sdcard.img  to $DEV ; ok?" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo dd if=$OUTPUT_DIR/images/sdcard.img of=$DEV bs=4M conv=fsync status=progress
fi


#!/bin/bash

PASSPORT_UUID=c788d9de-d012-45d5-9663-2cfe17de9219
MOUNT=$(findmnt -n -S UUID=$PASSPORT_UUID -o TARGET)

echo "Restoring from $MOUNT"

if [ ! -d "$MOUNT" ]; then
    echo "Disk not mounted, refusing to continue"
    exit 1
fi

# @Note, the -n option to rsync is handy to test what will be backed up.
rsync -va --delete "$MOUNT/rsync/" "$HOME"



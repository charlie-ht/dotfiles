#!/bin/bash

CHROOT=$1
schroot -c "$CHROOT" -u $USER -d /home/$USER

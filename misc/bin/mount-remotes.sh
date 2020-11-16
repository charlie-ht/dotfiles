#!/bin/bash

# https://serverfault.com/questions/6709/sshfs-mount-that-survives-disconnect/639735
KEEP_ALIVE_OPTS='reconnect,ServerAliveInterval=15,ServerAliveCountMax=3'
sshfs -o $KEEP_ALIVE_OPTS router:/ $HOME/remotes/router
# The cache timeout here is long because I only edit things from my
# workstation, not from the router, so invalidation is not really an
# issue.
sshfs -o $KEEP_ALIVE_OPTS -o cache_timeout=$((60 * 60)) router:/mnt/extstorage $HOME/remotes/router-extstorage


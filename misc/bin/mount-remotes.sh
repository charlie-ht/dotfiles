#!/bin/bash

sshfs router:/ $HOME/remotes/router
sshfs -o cache_timeout=$((60 * 60)) router:/mnt/extstorage $HOME/remotes/router-extstorage


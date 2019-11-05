#!/bin/sh

# The blacklist is out-of-date as of 2017.
google-chrome --ignore-gpu-blacklist 2>&1>/dev/null

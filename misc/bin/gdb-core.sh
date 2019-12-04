#!/bin/bash

regex="execfn: '([^']+)'"
core_info=$(file $1)

if [[ $core_info =~ $regex ]]; then
    process_path=${BASH_REMATCH[1]}
    gdb $process_path $1
fi

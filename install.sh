#!/usr/bin/env bash

D=$(dirname $(readlink -f $0))

for pkg in bash config emacs gdb git misc ssh tmux x vim; do
    stow -d $D -t $HOME $pkg
done

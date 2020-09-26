#!/usr/bin/env bash

for pkg in bash config emacs gdb git misc ssh tmux x vim; do
    stow -t $HOME $pkg
done

#!/usr/bin/env bash

for pkg in bash emacs gdb git misc ssh tmux x vim; do
    stow -t $HOME $pkg
done

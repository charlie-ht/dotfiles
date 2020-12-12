# -*- shell-script -*-

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Don't capture <C-S>
stty stop undef

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Don't capture <C-S>
stty stop undef

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# do not truncate shell history at all.
HISTSIZE=-1
HISTFILESIZE=-1
PS1='\u@\e[4;32m\h\e[m [\W] ~ '


C=~/.bashrc.d
. $C/bash_options.bash

. $C/prelude.bash
. $C/aliases.bash
. $C/env.bash

. $C/debian.bash
. $C/email.bash
. $C/git.bash

. $C/go.bash
. $C/web.bash

. $C/gstreamer.bash
. $C/graphics.bash
. $C/buildroot.bash
. $C/webkit.bash

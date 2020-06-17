# -*- shell-script -*-

## general shell configuration

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

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# do not truncate shell history at all.
HISTSIZE=-1
HISTFILESIZE=-1

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

## interactive shell configuration
if [[ -n $PS1 ]]; then
    # See gpg-agent(1)
    GPG_TTY=$(tty)
    export GPG_TTY

    #https://unix.stackexchange.com/questions/90853/how-can-i-run-ssh-add-automatically-without-password-prompt
    if [ -z "$SSH_AUTH_SOCK" ] ; then
        { eval `ssh-agent -s` ; ssh-add ; } &>/dev/null
    fi

    trap 'test -n "$SSH_AUTH_SOCK" && eval `/usr/bin/ssh-agent -k` &> /dev/null' 0

    if [ -x /usr/bin/dircolors ]; then
        test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
        alias ls='ls --color=auto'
        alias dir='dir --color=auto'
        alias ll='ls --color=auto -alF'
        alias la='ls --color=auto -A'
        alias l='ls --color=auto -CF'
    fi

    alias e='emacsclient -n'
    export EDITOR='emacsclient'
    if [ -x $(which nvim) ]; then
        alias vim=nvim
        alias vi=nvim
        export VIMCONFIG=$HOME/.config/nvim
    fi
    export PAGER=less

    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'

    alias mkdir='mkdir -pv'

    if [ -x $(which pydf) ]; then
        alias df=pydf
    fi
    alias dir_size='du -sh'

    alias path="echo $PATH | tr ':' '\n'"
    alias pypath="echo $PYTHONPATH | tr ':' '\n'"

    alias wget='wget -c'
    alias myip='curl http://ipecho.net/plain; echo'
    alias myps='ps -U $(whoami) -u $(whoami) u'
    alias sprunge="curl -F 'sprunge=<-' http://sprunge.us"

    pathmunge ()
    {
        if ! echo "$PATH" | /bin/grep -Eq "(^|:)$1($|:)" ; then
            if [ "$2" = "after" ] ; then
                PATH="$PATH:$1"
            else
                PATH="$1:$PATH"
            fi
        fi
    }

    path_prepend_if_missing ()
    {
        local pathname="$1"
        if [ -d $pathname ]; then
            pathmunge $pathname
        fi
    }

    path_prepend_if_missing $HOME/bin
    path_prepend_if_missing $HOME/.local/bin

    if [[ -x $(which virtualenvwrapper.sh) ]]; then
        # FIXME: Grim interpreter selection
        VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3 source $(which virtualenvwrapper.sh)
    fi

    ewhich () {
        emacsclient -n $(which $1)
    }

    file_stats ()
    {
        echo "birth access mod status filename"
        /usr/bin/stat --format="%W %X %Y %Z %n" $@
    }

    rg_cpp()
    {
        rg -g "*.c" -g "*.cpp" -g "*.h" $@
    }

    rg_cmake()
    {
        rg -g "*.cmake" -g "CMakeLists.txt" $@
    }

    rg_gst()
    {
        if [[ $PWD == $HOME/gstreamer/gst-build ]]; then
            rg -g "*.c" -g "*.h" -L $@ subprojects/* 
        fi
    }

    gsearch()
    {
        local search_term=$(urlencode $@)
        local url="https://google.com/search?q=${search_term}"
        sensible-browser $url
    }

    copy_last_command ()
    {
        # http://stackoverflow.com/a/23710535/1777162
        history -p '!!' |tr -d \\n | clip;
    }

    simple_date ()
    {
        date +"%d%m%Y-%H%M%S"
    }

    top10_commands ()
    {
        history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n10
    }

    # 40% quality seems to give good compression ratio and the output
    # looks fine for the images I've needed to compress.
    img_compress ()
    {
        extension="${1##*.}"
        filename="${1%.*}"
        filename_smaller="${filename}_smaller"
        convert -strip -quality 40 $1 $filename_smaller.$extension
    }

    extract ()
    {
        if [ -z "$1" ]; then
	    # display usage if no parameters given
	    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
	    echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
	    return 1
        else
	    for n in $@
	    do
	        if [ -f "$n" ] ; then
		    case "${n%,}" in
		        *.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar) 
                            tar xvf "$n"       ;;
		        *.lzma)      unlzma ./"$n"      ;;
		        *.bz2)       bunzip2 ./"$n"     ;;
		        *.rar)       unrar x -ad ./"$n" ;;
		        *.gz)        gunzip ./"$n"      ;;
		        *.zip)       unzip ./"$n"       ;;
		        *.z)         uncompress ./"$n"  ;;
		        *.7z|*.arj|*.cab|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.rpm|*.udf|*.wim|*.xar)
                            7z x ./"$n"        ;;
		        *.xz)        unxz ./"$n"        ;;
		        *.exe)       cabextract ./"$n"  ;;
		        *)
                            echo "extract: '$n' - unknown archive method"
                            return 1
                            ;;
		    esac
	        else
		    echo "'$n' - file does not exist"
		    return 1
	        fi
	    done
        fi
    }

    c_html_template () {
        local name=$1
        cat <<EOF > $name
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<title>Your HTML5 Page...</title>
	<link rel="stylesheet" href="css/style.css">
	<!--[if IE]>
		<script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
	<![endif]-->
</head>

<body id="home">

	<h1>HTML5 boilerplate</h1>

</body>
</html>
EOF
    }


else
    # non-interactive shell configuration
    synax=1
fi

# Buildroot Configurations
export BR_OUTPUT_DIR=$HOME/igalia/buildroot/output
alias c_br_list_configs='make list-defconfigs'
alias c_br_full_rebuild='make clean all'
alias c_br_configure_busybox='make busybox-menuconfig'
alias c_br_configure_linux='make linux-menuconfig'
alias c_br_serial_rpi3='sudo picocom -b 115200 /dev/ttyUSB0'

c_br_rebuild_pkg ()
{
    local pkg=$1
    make ${pkg}_dirclean ${pkg}
}
c_br_ccache_set_max_size () {
    local limit=$1
    make CCACHE_OPTIONS="--max-size=${limit}" ccache-options
}
c_br_ccache_zero_stats () {
    make CCACHE_OPTIONS="--zero-stats" ccache-options
}

#######################
# GStreamer Functions #
#######################
c_gst_plugins() {
    plugin_name=$1
    IFS=:
    for path in $GST_PLUGIN_PATH ; do
	if [ -d $path ] ; then
	    find $path -name "*$plugin_name*"
	fi
    done
}

####################
# WebKit Functions #
####################

alias c_wk_test_results='x-www-browser file://$HOME/webkit-test/results.html'

export WK_SOURCE_DIR=$HOME/igalia/sources/WebKit

c_wk_enter() {
    gst_env=$($HOME/gstreamer/gst-build/gst-env.py --only-environment)
    >/tmp/bashrc
    cat ~/.bashrc >> /tmp/bashrc
    cat <<EOF >> /tmp/bashrc

$gst_env

export PS1="[webkit] $PS1"
export WEBKIT_SRC=$WK_SOURCE_DIR
export PATH=\$PATH:\$WEBKIT_SRC/Tools/Scripts

cd \$WEBKIT_SRC
git status
ulimit -c unlimited
EOF

    bash --rcfile /tmp/bashrc
}


c_wk_grep_expectations () {
    find $WK_SOURCE_DIR/LayoutTests -name "TestExpectations" | xargs grep -rn $@
}

# Git

# When you've forgotten everything again, git help -ag is useful to
# see all the stuff you need to read again...
alias gith='git help -w'
alias git_clean_whitespace='git diff --cached --no-color > stage.diff && git apply --index -R stage.diff && git apply --index --whitespace=fix stage.diff && rm -f stage.diff'

c_git_find_reviewers () {
    git blame --line-porcelain $1 | sed -n 's/^author //p' | sort | uniq -c | sort -rn
}

c_git_ignore_untracked_files () {
    git status --porcelain | grep '^??' | cut -c4- >> .gitignore
}

# Email 

c_igalia_db () {
    command=$1
    shift
    notmuch $command 'path:igalia/**' and $@
}

c_gmail_db () {
    command=$1
    shift
    notmuch $command 'path:chturne_gmail/**' and $@
}

# Debian
alias cdeb_pkg_update='sudo apt update'
alias cdeb_pkg_install='sudo apt install'
alias cdeb_pkg_upgrade='sudo apt upgrade'
cdeb_pkg_remove ()
{
    sudo apt remove $1 && sudo apt purge $1 && sudo apt autoclean
}
alias cdeb_pkg_autoremove='sudo apt autoremove'
alias cdeb_pkg_info='apt show'
alias cdeb_pkg_search='apt search'
alias cdeb_pkg_why='aptitude why'
alias cdeb_pkg_list_manuals="aptitude search '~i!~M'"

search_wk_list()
{
    gsearch "site:lists.webkit.org $@"
}
cdeb_search_home()
{
    gsearch "site:debian.org $@"
}
cdeb_search_wiki()
{
    gsearch "site:wiki.debian.org $@"
}
cdeb_search_lists()
{
    gsearch "site:lists.debian.org $@"
}
cdeb_openbug () {
	local id=$1
	local url="http://bugs.debian.org/${id}"
	sensible-browser $url
}
cdeb_pkgbugs () {
	local pkg=$1
	local url="http://bugs.debian.org/${pkg}"
	sensible-browser $url
}

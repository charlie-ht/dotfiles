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

# don't put duplicate lines or lines starting with space in the history.

# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

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
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias df='df -Tha --total'
alias free='free -mt'
alias mkdir='mkdir -pv'
alias wget='wget -c'
alias top=htop
alias df=pydf
alias c_dir_size='du -sh'
alias c_myip='curl http://ipecho.net/plain; echo'
alias c_myps='ps -U $(whoami) -u $(whoami) u'
alias c_sprunge="curl -F 'sprunge=<-' http://sprunge.us"
alias c_find_c_or_cpp_files='find . -name "*.cpp" -o -name "*.c" -o -name "*.h" -o -name "*.hpp" -o -name "*.cc" -o -name "*.cxx" -o -name "*.hxx"'
alias pypath="echo $PYTHONPATH | tr ':' '\n'"

function c_file_times()
{
    echo "birth access mod status filename"
    /usr/bin/stat --format="%W %X %Y %Z %n" $@
}

# http://stackoverflow.com/a/23710535/1777162
function c_copy_last_command()
{
    history -p '!!' |tr -d \\n | clip;
}

function c_simple_date()
{
	date +"%d%m%Y-%H%M%S"
}

# Return the top-10 most common commands in your history.
function c_top10_commands()
{
    history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n10
}

# 40% quality seems to give good compression ratio and the output
# looks fine for the images I've needed to compress.
function c_img_compress()
{
	extension="${1##*.}"
	filename="${1%.*}"
	convert -strip -quality 40 $1 $filename_smaller.$extension
}

function c_extract {
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

function c_fd() {
    local name=$1
    find . -name "*$name*"
}

function ewhich() {
    $HOME/stage/bin/emacsclient -n $(which $1)
}

function c_view_dot() {
    dot -Tpdf -o /tmp/dot.pdf $1
}

function c_html_template() {
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

## Buildroot helpers
alias c_br_list_configs='make list-defconfigs'
alias c_br_full_rebuild='make clean all'
alias c_br_configure_busybox='make busybox-menuconfig'
alias c_br_configure_linux='make linux-menuconfig'
alias c_br_serial_rpi3='sudo picocom -b 115200 /dev/ttyUSB0'

function c_br_metro_enter()
{
    local base_dir="$HOME/buildroot/metro/buildroot"
    if ! [[ -d $base_dir ]]; then
        echo "metro buildroot checkout does not exist"
        return 1
    fi

    pushd $base_dir &> /dev/null
    head=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)
    cp ~/.bashrc /tmp/wk_bashrc
    cat  >> /tmp/wk_bashrc <<EOF
export PS1="\n[metro buildroot $head]\n$PS1"
EOF
    bash --rcfile /tmp/wk_bashrc
    popd &> /dev/null
}

function c_br_save_config()
{
	make savedefconfig BR2_DEFCONFIG=defconfig-$(c_simple_date)
}

function c_br_rebuild_pkg()
{
	local pkg=$1
	make ${pkg}_dirclean ${pkg}
}
function c_br_ccache_set_max_size() {
	local limit=$1
	make CCACHE_OPTIONS="--max-size=${limit}" ccache-options
}
function c_br_ccache_zero_stats() {
	make CCACHE_OPTIONS="--zero-stats" ccache-options
}

### GStreamer
function c_gst_enter() {
    pushd $HOME/gstreamer/gst-build &>/dev/null
    ninja -C build/ uninstalled
    popd &>/dev/null
}

function c_gst_plugins() {
	plugin_name=$1
	IFS=:
	for path in $GST_PLUGIN_PATH ; do
		if [ -d $path ] ; then
			find $path -name "*$plugin_name*"
		fi
	done
}

### WebKit
export WK_SOURCE_DIR=$HOME/webkit/WebKit
function c_wk_grep_expectations() {
    find $WK_SOURCE_DIR/LayoutTests -name "TestExpectations" | xargs grep -rn $@
}

alias c_wk_test_results='x-www-browser file://$HOME/webkit-test/results.html'

### Git
# When you've forgotten everything again, git help -ag is useful to
# see all the stuff you need to read again...
alias gith='git help -w'

function c_git_find_reviewers() {
    git blame --line-porcelain $1 | sed -n 's/^author //p' | sort | uniq -c | sort -rn
}

function c_git_ignore_untracked_files() {
    git status --porcelain | grep '^??' | cut -c4- >> .gitignore
}

## Mail utilities
function c_igalia_db() {
    command=$1
    shift
    notmuch $command 'path:igalia/**' and $@
}

function c_gmail_db() {
    command=$1
    shift
    notmuch $command 'path:chturne_gmail/**' and $@
}

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

GPG_TTY=$(tty)
export GPG_TTY

#https://unix.stackexchange.com/questions/90853/how-can-i-run-ssh-add-automatically-without-password-prompt
if [ -z "$SSH_AUTH_SOCK" ] ; then
  { eval `ssh-agent -s` ; ssh-add ; } &>/dev/null
fi

trap 'test -n "$SSH_AUTH_SOCK" && eval `/usr/bin/ssh-agent -k` &> /dev/null' 0

# Note that you have to press Enter before this escape key in Mosh, similar to SSH.
export MOSH_ESCAPE_KEY='~'

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
alias !='sudo'

function c_mcd () {
    mkdir -p $1
    cd $1
}

function c_open_dot_files()
{
    for dot in $@; do
        basename=$(basename -- "$dot")
        dot -Tpdf $dot -o /tmp/$basename.pdf
        echo "Viewing $dot"
        google-chrome /tmp/$basename.pdf
        read -p "Enter key to continue"
        rm /tmp/$basename.pdf
    done
}

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

function c_c99() {
	cc -std=c99 -g -Wall $1 -o ${1%.*}
}

function c_c++14() {
	c++ -std=c++14 -Wall $1 -o ${1%.*}
}

function c_c++latest() {
	c++ -std=c++1z -Wall $1 -o ${1%.*}
}

alias c_find_c_or_cpp_files='find . -name "*.cpp" -o -name "*.c" -o -name "*.h" -o -name "*.hpp" -o -name "*.cc" -o -name "*.cxx" -o -name "*.hxx"'
function c_fd() {
    local name=$1
    find . -name "*$name*"
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

## WebKit
function c_wk_enter()
{
    if [[ $# -ne 2 ]]; then
        echo "c_wk_enter (gtk|wpe) (rel|dbg)"
        return 1
    fi

    local port=$1
    local type=$2

    if [[ $port != "gtk" ]] && [[ $port != "wpe" ]]; then
        echo "unknown port";
        return 1
    fi

    if [[ $type != "rel" ]] && [[ $type != "dbg" ]]; then
        echo "unknown build type"
        return 1
    fi

    local base_dir="$HOME/webkit/$port"
    if ! [[ -d $base_dir ]]; then
        echo "webkit checkout does not exist"
        return 1
    fi

    pushd $base_dir &> /dev/null
    head=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)
    cp ~/.bashrc /tmp/wk_bashrc
    cat  >> /tmp/wk_bashrc <<EOF
export PS1="\n[$port $head]\n$PS1"
export C_WEBKIT_PORT=$port
export C_WEBKIT_BUILD_TYPE=$type
export C_WEBKIT_BASEDIR=$base_dir
export PATH=$base_dir/Tools/Scripts:$PATH
export NUMBER_OF_PROCESSORS=4
EOF

    bash --rcfile /tmp/wk_bashrc
    popd &> /dev/null
}

function _c_wk_check_inside_tree()
{
    if ! [[ -v C_WEBKIT_PORT ]]; then
        echo "not inside webkit tree";
        return 1;
    fi;
    if [[ -z $GST_ENV || $GST_ENV -ne "gst-master" ]]; then
        echo "Not in a gst-master uninstalled environment, aborting!"
        return 1
    fi
    return 0
}

function c_wk_build_for_eme()
{
    if ! _c_wk_check_inside_tree; then
        return 1;
    fi;

    local build_type=release
    if [[ $C_WEBKIT_BUILD_TYPE == "dbg" ]]; then
        build_type=debug
    fi

    env CXXFLAGS="-DLOG_DISABLED=0" \
        $C_WEBKIT_BASEDIR/Tools/Scripts/build-webkit \
        --$C_WEBKIT_PORT \
        --$build_type \
        --cmakeargs='-DUSE_WIDEVINE=1' \
        --encrypted-media --media-source \
        --no-web-rtc --no-media-stream `# webrtc bundles boringssl, which conflicts in widevine` \
        --no-bubblewrap-sandbox `# i don't have a new enough bwrap`
}

function c_wk_quick_rebuild()
{
    if ! _c_wk_check_inside_tree; then
        return 1;
    fi;

    local build_type=Release
    if [[ $C_WEBKIT_BUILD_TYPE == "dbg" ]]; then
        build_type=Debug
    fi

    $C_WEBKIT_BASEDIR/Tools/jhbuild/jhbuild-wrapper --$C_WEBKIT_PORT run \
        cmake --build $C_WEBKIT_BASEDIR/WebKitBuild/$build_type \
              --config $build_type -- -j$NUMBER_OF_PROCESSORS bin/MiniBrowser
}

function c_wk_available_features()
{
    if ! _c_wk_check_inside_tree; then
        return 1;
    fi;

    rg -A1 'option =>' $C_WEBKIT_BASEDIR/Tools/Scripts/webkitperl/FeatureList.pm | less
}

function c_wk_run_tests()
{
    if ! _c_wk_check_inside_tree; then
        return 1;
    fi;
    TESTS='media/encrypted-media imported/w3c/web-platform-tests/encrypted-media';

    local build_type=release
    if [[ $C_WEBKIT_BUILD_TYPE == "dbg" ]]; then
        build_type=debug
    fi

    GST_DEBUG='*:2,webkit*:MEMDUMP,webkitmse:MEMDUMP,*protection*:MEMDUMP'
    GST_DEBUG_DUMP_DOT_DIR=
    for arg in $*; do
        case $arg in
            --gst_dot_dump)
                shift
                GST_DEBUG_DUMP_DOT_DIR=/tmp
                ;;
            --gst_add_log)
                shift
                log=$1
                shift
                GST_DEBUG="$GST_DEBUG,$log"
                ;;
            *)
                ;;
        esac
    done

    if [[ $# -gt 0 ]]; then
        TESTS=$@;
    fi;

    run-webkit-tests --$C_WEBKIT_PORT \
                     --$build_type \
                     --additional-env-var='G_DEBUG=fatal-criticals' \
                     --additional-env-var="GST_DEBUG_DUMP_DOT_DIR=$GST_DEBUG_DUMP_DOT_DIR" \
                     --additional-env-var="GST_DEBUG=*:3,webkit*:MEMDUMP" \
                     --additional-env-var='GST_DEBUG_NO_COLOR=1' \
                     --additional-env-var='WEBKIT_DEBUG=EME,Events,Media,MediaCaptureSamples,MediaQueries,MediaSource,MemoryPressure,PerformanceLogging,PlatformLeaks,ResourceLoading,Threading,WebAudio' \
                     --no-retry-failures \
                     --allowed-host='lic.staging.drmtoday.com' \
                     $TESTS
}

function c_wk_run_mb()
{
    if ! _c_wk_check_inside_tree; then
        return 1;
    fi;

    URL='https://webkitgtk.org'
    GST_DEBUG='*:2,webkit*:DEBUG'
    if [[ $# -gt 1 ]]; then
        GST_DEBUG=$1
        URL=$2
    elif [[ $# -gt 0 ]]; then
        URL=$1
    fi

    local build_type=release
    if [[ $C_WEBKIT_BUILD_TYPE == "dbg" ]]; then
        build_type=debug
    fi

    logfile=$(mktemp minibrowser-run.XXX)

    env G_DEBUG='fatal-criticals' \
        GST_DEBUG_DUMP_DOT_DIR=/tmp \
        GST_DEBUG=$GST_DEBUG \
        GST_DEBUG_NO_COLOR=1 \
        WEBKIT_DEBUG='EME,Media,Events' \
        run-minibrowser --$build_type --$C_WEBKIT_PORT --enable-write-console-messages-to-stdout=1 \
           --enable-mediasource=1 --enable-encrypted-media=1 \
           --user-agent="Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:64.0) Gecko/20100101 Firefox/64.0" \
           -c netflix.cookies $URL |& tee $logfile

    echo $logfile
}

function c_wk_grep_headers()
{
    if ! _c_wk_check_inside_tree; then
        return 1;
    fi;

    local pattern=$1

    pushd $C_WEBKIT_BASEDIR/Source &>/dev/null
    fd -e h | xargs rg --heading -n $pattern | less
    popd &>/dev/null
}

function c_wk_grep_source()
{
    if ! _c_wk_check_inside_tree; then
        return 1;
    fi;

    local pattern=$1

    pushd $C_WEBKIT_BASEDIR/Source &>/dev/null
    fd -e h -e cpp | xargs rg --heading -n $pattern | less
    popd &>/dev/null
}

function c_wk_grep_source()
{
    if ! _c_wk_check_inside_tree; then
        return 1;
    fi;

    local pattern=$1

    pushd $C_WEBKIT_BASEDIR/Source &>/dev/null
    fd -e cmake -e cpp | xargs rg --heading -n $pattern | less
    popd &>/dev/null
}

function c_wk_grep_build()
{
    if ! _c_wk_check_inside_tree; then
        return 1;
    fi;

    local pattern=$1

    pushd $C_WEBKIT_BASEDIR/ &>/dev/null
    # I don't think fd supports alternations, so keeping GNU Find here.
    find -name "*.cmake" -o -name "CMakeLists.txt" | xargs rg --heading -n $pattern | less
    popd &>/dev/null
}

function c_wk_jhbuild_rebuild_gstreamer()
{
    if ! _c_wk_check_inside_tree; then
        return 1;
    fi;

    $C_WEBKIT_BASEDIR/Tools/jhbuild/jhbuild-wrapper --$C_WEBKIT_PORT buildone -nf gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-libav gstreamer-vaapi
}

function c_wk_show_test_stderr()
{
    if ! _c_wk_check_inside_tree; then
        return 1;
    fi;

    if [ $# -ne 1 ]; then
        echo "provide portion of a test name, without the html extension"
    fi

    local build_type=Release
    if [[ $C_WEBKIT_BUILD_TYPE == "dbg" ]]; then
        build_type=Debug
    fi

    local test_name=$1

    fd "$test_name.*stderr" $C_WEBKIT_BASEDIR/WebKitBuild/$build_type/layout-test-results/
}

function c_wk_last_core()
{
    if ! _c_wk_check_inside_tree; then
        return 1;
    fi;

    local build_type=Release
    if [[ $C_WEBKIT_BUILD_TYPE == "dbg" ]]; then
        build_type=Debug
    fi

    coredumpctl gdb $C_WEBKIT_BASEDIR/WebKitBuild/$build_type/bin/WebKitWebProcess
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

## Pharo
# The launcher is just a shell, the VM images are kept in ~Pharo (backed up)
alias pharo='~/pharolauncher/pharo-launcher'

## Mail utilities
function igalia_mail_db() {
    command=$1
    shift
    notmuch $command 'path:igalia/**' and $@
}

function gmail_db() {
    command=$1
    shift
    notmuch $command 'path:chturne_gmail/**' and $@
}

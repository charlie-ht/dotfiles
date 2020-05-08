#!/bin/bash

D=$(dirname $(readlink -f $0))
source $D/common.sh
source $D/webkit-common.sh

src_dir=$HOME/igalia/sources/WebKit
gst_debug='*:2,webkit*:6'
logging=

usage() {
    echo_heading "Usage:"
    echo
    echo "  WebKit testing launch script"
    echo "      --build-type=debug|release  [REQUIRED]"
    echo "      --port=gtk|wpe [DEFAULT=gtk]"
    echo "      --branch=<branch-name> - will select a different branch build [DEFAULT=current branch in srcdir]"
    echo "      --webkit-src-dir=/some/path - path to WebKit source directory, useful for worktrees [DEFAULT $src_dir]"
    echo "      --gst-debug=*:2             - set the GST_DEBUG variable"
    echo "      --debug - will pause the WebProcess on startup to allow GDB attachment"
    echo "      ... - remaining args are paths under LayoutTests. My default is http/tests/media fast/media fast/mediastream media imported/w3c/web-platform-tests/media imported/web-platform-tests/encrypted-media imported/w3c/web-platform-tests/media-source webaudio"
    echo "      --eme    - run a set of tests for EME"
    echo "      --logging - run tests with logging output, not this may break the tests with meaningless text diffs (logging to stderr)"
    echo "      --find-files test-name - finds all outputs in both the results directory and LayoutTests directory"
    echo "                  e.g $0 --find-files clearkey-check-status-for-hdcp"
    echo
}

while test -n "$1"; do
    case "$1" in
        --find-files)
            name=$2
            find ~/webkit-test/ $src_dir/LayoutTests/ -name "*$name*"
            rg -g TestExpectations ".*$name.*" $src_dir/LayoutTests/
            exit 0
            shift
            ;;
        --logging)
            logging=1
            ;;
        --media)
            tests='http/tests/media fast/media fast/mediastream media imported/w3c/web-platform-tests/media imported/w3c/web-platform-tests/encrypted-media imported/w3c/web-platform-tests/media-source webaudio'
            ;;
        --eme)
            tests='media/encrypted-media imported/w3c/web-platform-tests/encrypted-media/clearkey* http/tests/media/clearkey'
            ;;
        --gst-debug=*)
            gst_debug="${1#--gst-debug=}"
            ;;
        --webkit-src-dir=*)
            src_dir="${1#--webkit-src-dir=}"
            ;;
        --build-type=*)
            build_type="${1#--build-type=}"
            if ! test "$build_type" = "debug" -o "$build_type" = "release"; then
                echo_error "build type should be debug or release"
                exit 1
            fi
            # map the build type information into CMake-speak
            case "$build_type" in
                *release*)
                    build_type="RelWithDebInfo"
                    ;;
                *debug*)
                    build_type="Debug"
                    ;;
            esac
            ;;
        --port=*)
            port="${1#--port=}"
            if ! test "$port" = "gtk" -o "$port" = "wpe"; then
                echo_error "port should be gtk or wpe"
                exit 1
            fi
            ;;
        --branch=*)
            branch="${1#--branch=}"
            ;;
        --debug*)
            debugging="yes"
            ;;
        *)
            passthru="$passthru $1"
            ;;
    esac
    shift
done

if test -z "$build_type"; then
    echo_warning "no build type given, default to debug"
    build_type="Debug"
fi
if test -z "$port"; then
    echo_warning "no port given, default to gtk"
    port=gtk
fi

if test -z "$src_dir"; then
    echo_error "no source directory given, aborting"
    usage
    exit 1
fi
if test -z "$branch"; then
    branch=$(git -C $src_dir rev-parse --abbrev-ref HEAD | sed -e 's/[^A-Za-z0-9._-]/_/g')
    branch=$(echo $branch | sed -e 's/[^A-Za-z0-9._-]/_/g')
fi

#FIXME: Hardcoding WebKit for the srcdir is confusing, but I don't run tests for non-master repos currently.
build_dir=$HOME/igalia/webkit-build-WebKit-$port-$branch-$build_type
if ! test -d "$build_dir"; then
    echo_error "no build product for $build_dir"
    usage
    exit 1
fi
if ! test -d "$build_dir/webkitgtk-test-fonts"; then
    echo_heading "Cloning test fonts into $build_dir"
    git clone "https://github.com/WebKitGTK/webkitgtk-test-fonts.git" "$build_dir/webkitgtk-test-fonts"
    if test ! $? -eq 0; then
        echo_error "failed to clone webkitgtk test fonts, aborting"
        usage
        exit 1
    fi
fi

echo_heading "Testing product in $build_dir"

export PYTHONPATH=$PYTHONPATH:$src_dir/Tools/Scripts
export WEBKIT_OUTPUTDIR=$build_dir

if test -n "$debugging"; then
    echo_heading "In debug mode, attach a debugger! ($debugging)"
    test_flags="--additional-env-var=WEBKIT2_PAUSE_WEB_PROCESS_ON_LAUNCH=1 --no-timeout"
fi

rm -f ~/cores/*

# These are the debugging output flags
# I can't figure out how to conditionally expand them
# into the mega-command line below. If you unconditionally
# include them, layout tests will fail due to the text output to stderr by these options
# --additional-env-var="WEBKIT_DEBUG=Media,EME,Events,ProcessSuspension" \
# --additional-env-var="GST_DEBUG=$gst_debug" \
# --additional-env-var="GST_DEBUG_NO_COLOR=1" \
# --additional-env-var="GST_DEBUG_DUMP_DOT_DIR=$HOME/gstreamer-dumps/" \

time jhbuild -f $JHBUILDRC -m $JHBUILD_MODULES run \
        env WEBKIT_CORE_DUMPS_DIRECTORY=$HOME/cores \
	$src_dir/Tools/Scripts/run-webkit-tests \
        --additional-env-var="GST_PLUGIN_SYSTEM_PATH=$GST_PLUGIN_SYSTEM_PATH" \
        --additional-env-var="GST_PLUGIN_PATH=$GST_PLUGIN_PATH" \
        --additional-env-var="GST_REGISTRY=$GST_REGISTRY" \
        --additional-env-var="GST_PLUGIN_SCANNER=$GST_PLUGIN_SCANNER" \
        --additional-env-var="GST_PRESET_PATH=$GST_PRESET_PATH" \
        --additional-env-var="DISABLE_NI_WARNING=1" \
	--debug-rwt-logging \
	--platform=$port \
	--results-directory=$HOME/webkit-test \
	--root=$build_dir \
	--build-directory=$build_dir \
	--no-build \
	--order=random \
	--child-processes=8 \
	--no-show-results \
	--no-retry-failures \
	$passthru $tests

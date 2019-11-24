#!/bin/bash

D=$(dirname $(readlink -f $0))
source $D/common.sh
source $D/webkit-common.sh

src_dir=$HOME/webkit/WebKit
gst_debug='*:2'

while test -n "$1"; do
    case "$1" in
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
    echo_error "no build type given, aborting"
    exit 1
fi
if test -z "$port"; then
    echo_warning "no port given, default to gtk"
    port=gtk
fi
if test -z "$src_dir"; then
    echo_error "no source directory given, aborting"
    exit 1
fi
if test -z "$branch"; then
    branch=$(git -C $src_dir rev-parse --abbrev-ref HEAD | sed -e 's/[^A-Za-z0-9._-]/_/g')
    branch=$(echo $branch | sed -e 's/[^A-Za-z0-9._-]/_/g')
fi

build_dir=$HOME/webkit/build-$port-$branch-$build_type
if ! test -d "$build_dir"; then
    echo_error "no build product for $port-$branch-$build_type"
    exit 1
fi
if ! test -d "$build_dir/webkitgtk-test-fonts"; then
    echo_heading "Cloning test fonts into $build_dir"
    git clone "https://github.com/WebKitGTK/webkitgtk-test-fonts.git" "$build_dir/webkitgtk-test-fonts"
    if test ! $? -eq 0; then
        echo_error "failed to clone webkitgtk test fonts, aborting"
        exit 1
    fi
fi

export PYTHONPATH=$PYTHONPATH:$src_dir/Tools/Scripts
export WEBKIT_OUTPUTDIR=$build_dir

if test -n "$debugging"; then
    echo_heading "In debug mode, attach a debugger! ($debugging)"
    debug_args="--additional-env-var=WEBKIT2_PAUSE_WEB_PROCESS_ON_LAUNCH=1 --no-timeout"
fi

if test -n "$gst_debug"; then
    echo_heading "Dumping GStreamer dot files to /tmp"
    dump_dots_args="--additional-env-var=GST_DEBUG_DUMP_DOT_DIR=$HOME/gstreamer-dumps/"
fi

export WEBKIT_CORE_DUMPS_DIRECTORY=$HOME/cores
time jhbuild -f $JHBUILDRC -m $JHBUILD_MODULES run \
	$src_dir/Tools/Scripts/run-webkit-tests \
	--additional-env-var="GST_PLUGIN_SYSTEM_PATH=$GST_PLUGIN_SYSTEM_PATH" \
	--additional-env-var="GST_PLUGIN_PATH=$GST_PLUGIN_PATH" \
	--additional-env-var="GST_REGISTRY=$GST_REGISTRY" \
	--additional-env-var="GST_PLUGIN_SCANNER=$GST_PLUGIN_SCANNER" \
	--additional-env-var="GST_PRESET_PATH=$GST_PRESET_PATH" \
	--additional-env-var='WEBKIT_DEBUG=Media,Events' \
	--additional-env-var="GST_DEBUG=$gst_debug" \
	--additional-env-var="GST_DEBUG_NO_COLOR=1" \
	$dump_dots_args \
	$debug_args \
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
	$passthru

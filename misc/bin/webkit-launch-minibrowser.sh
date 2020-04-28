#!/bin/bash

D=$(dirname $(readlink -f $0))

source $D/common.sh
source $D/webkit-common.sh

GST_DEBUG='*:2,webkit*:2'
WEBKIT_DEBUG='EME,Media,Events'

while test -n "$1"; do
    case "$1" in
        --gst-debug=*)
            GST_DEBUG="${1#--gst-debug=}"
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
        --run-strace*)
            run_strace="yes"
            ;;
        --branch=*)
            branch="${1#--branch=}"
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

check_branch
normalize_branch

echo_heading "Running minibrowser for $port:$branch in configuration $build_type"
build_dir=$HOME/igalia/webkit-build-WebKit-$port-$branch-$build_type
if ! test -d "$build_dir"; then
    echo_error "no build product for $build_dir"
    exit 1
fi

cmd_prefix="jhbuild -f $JHBUILDRC -m $JHBUILD_MODULES run"

if test -n "$run_strace"; then
   cmd_prefix="strace -f -e trace=stat $cmd_prefix"
fi

#cmd_prefix="rr record jhbuild -f $JHBUILDRC -m $JHBUILD_MODULES run"

>run.log
echo_heading "MiniBrowser run for $port:$branch in configuration $build_type" >>run.log

rm -rf ~/.cache/MiniBrowser
rm /tmp/*.dot
 env Malloc=1 \
    G_DEBUG=fatal-criticals,fatal-warnings,gc-friendly \
    G_SLICE=always-malloc \
    GST_DEBUG=$GST_DEBUG \
    GST_DEBUG_DUMP_DOT_DIR=/tmp/ \
    WEBKIT_DEBUG=$WEBKIT_DEBUG \
    DISABLE_NI_WARNING=1 \
    $cmd_prefix $build_dir/bin/MiniBrowser \
    --enable-write-console-messages-to-stdout=1 \
    --enable-encrypted-media=1 \
    --enable-mediasource=1 \
    --user-agent='Mozilla/5.0 (Macintosh, Intel Mac OS X 10_11_4) AppleWebKit/602.1.28+ (KHTML, like Gecko) Version/9.1 Safari/601.5.17 Horizon_STB_SMT-G7400/602.1.28 (LibertyGlobal, Horizon, Wired)' \
    $passthru |& tee -a run.log


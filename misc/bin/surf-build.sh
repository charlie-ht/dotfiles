#!/bin/bash

D=$(dirname $(readlink -f $0))
source $D/webkit-common.sh

while test -n "$1"; do
    case "$1" in
        --branch=*)
            branch="${1#--branch=}"
            ;;
        --port=*)
            port="${1#--port=}"
            if ! test "$port" = "gtk" -o "$port" = "wpe"; then
                echo_error "port should be gtk or wpe"
                exit 1
            fi
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
if test -z "$branch"; then
    echo_error "no branch given, aborting"
    exit 1
fi

build_dir=$HOME/git/surf

jhbuild_lib_dir=$HOME/webkit/deps-prefix/root/lib

webkit_install_dir=$HOME/webkit/install-$port-$branch-$build_type
if test ! -d $webkit_install_dir; then
    echo_error "install dir ($webkit_install_dir) missing, aborting"
    exit 1
fi

pushd $build_dir 2>&1>/dev/null

make clean

jhbuild -f $JHBUILDRC -m $JHBUILD_MODULES run \
        env LD_LIBRARY_PATH=$webkit_install_dir/lib:$jhbuild_lib_dir \
        PKG_CONFIG_PATH=$webkit_install_dir/lib/pkgconfig:$jhbuild_lib_dir/pkgconfig:$PKG_CONFIG_PATH \
        make

popd 2>&1>/dev/null

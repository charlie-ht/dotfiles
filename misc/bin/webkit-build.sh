#!/bin/bash

# To build from widevine src dir (a git worktree)
# webkit-build.sh --src-dir=$HOME/webkit/webkit-widevine --build-type=release --incr
# To run this widevine build, I make the assumption that the worktree is built in a unique branch name, so the cmd is
# webkit-launch-minibrowser.sh --port=gtk --build-type=release --branch=widevine-r246539 <url>

D=$(dirname $(readlink -f $0))
source $D/common.sh
source $D/webkit-common.sh

extra_cmake_args=''

while test -n "$1"; do
    case "$1" in
        --clang)
            CXX=/usr/lib/icecc/bin/clang++
            CC=/usr/lib/icecc/bin/clang
            ;;
        --src-dir=*)
            src_dir="${1#--src-dir=}"
            ;;
        --force-rebuild)
            force_rebuild="yes"
            ;;
        --incr*)
            incremental_build="yes"
            ;;
        --build-deps)
            build_deps="yes"
            ;;
        --num-cores=*)
            num_cores="${1#--num-cores=}"
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
        --extra-cmake-args=*)
            extras="${1#--extra-cmake-args=}"
            extra_cmake_args="$extra_cmake_args $extras"
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

# handy way to check enviornment
# jhbuild -f $JHBUILDRC -m $JHBUILD_MODULES build run printenv

if test -n "$build_deps"; then
    echo_heading "=== Updating WebKit dependencies"
    jhbuild -f $JHBUILDRC -m $JHBUILD_MODULES build
fi

check_branch
normalize_branch

echo_heading "Building $port:$branch in configuration $build_type"

build_dir=$HOME/webkit/build-$port-$branch-$build_type
if ! test -d "$build_dir"; then
    mkdir $build_dir
fi

install_prefix=$HOME/build/webkit/install-$port-$branch-$build_type

echo_heading "=== Configuring WebKit"
pushd $build_dir 2>&1>/dev/null

if test -n "$force_rebuild"; then
    read -p "Removing everything in $install_prefix and $build_dir; ok?" -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
	rm -rf $install_prefix
	rm -rf $build_dir
    fi
fi

OUR_JHBUILD_PREFIX=$(jhbuild -f $JHBUILDRC -m $JHBUILD_MODULES run env | grep JHBUILD_PREFIX= | cut -f2 -d=)

export CXXFLAGS='-DLOG_DISABLED=0'
if test -z "$incremental_build"; then
    echo_heading "Reconfiguring build-directory"
    jhbuild -f $JHBUILDRC -m $JHBUILD_MODULES run \
	  env ICU_ROOT=$HOME/webkit/deps-prefix/root CC=$CC CXX=$CXX cmake $src_dir \
	  -G Ninja \
	  -DPORT=${port^^} \
	  -DCMAKE_BUILD_TYPE=$build_type \
	  -DCMAKE_INSTALL_PREFIX="$install_prefix" \
	  -DENABLE_GTKDOC=OFF \
	  -DENABLE_EXPERIMENTAL_FEATURES=ON \
	  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
	  -DDEVELOPER_MODE=ON \
	  -DENABLE_MINIBROWSER=ON \
	  -DENABLE_BUBBLEWRAP_SANDBOX=OFF \
          -DENABLE_MEDIA_SOURCE=ON \
          -DENABLE_ENCRYPTED_MEDIA=ON \
          -DLOG_DISABLED=0 \
          -DRELEASE_LOG_DISABLED=0 \
	  $extra_cmake_args
    echo_heading "Running Ninja"
    time jhbuild -f $JHBUILDRC -m $JHBUILD_MODULES run ninja -j$NUM_CORES
else
    echo_warning "WARNING!! Incremental rebuild ($build_dir)"

    time jhbuild -f $JHBUILDRC -m $JHBUILD_MODULES run \
	 cmake --build $build_dir \
         --config $build_type -- -j$NUM_CORES bin/MiniBrowser
fi

popd 2>&1>/dev/null



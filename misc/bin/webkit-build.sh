#!/bin/bash

# To build from widevine src dir (a git worktree)
# webkit-build.sh --src-dir=$HOME/webkit/webkit-widevine --build-type=release --incr
# To run this widevine build, I make the assumption that the worktree is built in a unique branch name, so the cmd is
# webkit-launch-minibrowser.sh --port=gtk --build-type=release --branch=widevine-r246539 <url>

D=$(dirname $(readlink -f $0))
source $D/common.sh
source $D/webkit-common.sh

extra_cmake_args=''
num_cores=$NUM_CORES
incremental_build=1

CC=$HOME/devenv/icecc/clang
CXX=$HOME/devenv/icecc/clang++
export ICECC_VERSION=$HOME/devenv/clang-head.tar.gz

while test -n "$1"; do
    case "$1" in
        --build-app)
            ## FIXME: The intent is to provide an easy way to build an
            ## app against the build git product. wkb
            ## --build-app=webkit-playground.c will build
            ## webkit-playgroud.c against the dev libraries.
            ## You must then be careful to run it in a good env, see run
            shift
            build_app="$1"
            ;;
        --run-app)
            ## FIXME: Consolidating to the wk master script really needs doing
            shift
            run_app="$1"
            ;;
        --src-dir=*)
            src_dir="${1#--src-dir=}"
            ;;
        --rebuild)
            incremental_build=
            ;;
        --build-deps)
            build_deps="yes"
            ;;
        --num-cores=*)
            num_cores="${1#--num-cores=}"
            ;;
        --release)
            build_type="RelWithDebInfo"
            ;;
        --debug)
            build_type="Debug"
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
    echo_warning "no build type given, default to debug"
    build_type="Debug"
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

install_prefix=$HOME/build/webkit/install-$port-$branch-$build_type

echo_heading "Building $port:$branch in configuration $build_type"
build_dir=$HOME/igalia/webkit-build-$(basename $src_dir)-$port-$branch-$build_type
if ! test -d "$build_dir"; then
    mkdir $build_dir
fi

echo_heading "=== Configuring WebKit"
pushd $build_dir 2>&1>/dev/null

# FIXME: not used anymore, but confirm logic is handy to keep
if test -n "$force_rebuild"; then
    read -p "Removing everything in $install_prefix and $build_dir; ok?" -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
	rm -rf $install_prefix
	rm -rf $build_dir
    fi
fi

OUR_JHBUILD_PREFIX=$(jhbuild -f $JHBUILDRC -m $JHBUILD_MODULES run env | grep JHBUILD_PREFIX= | cut -f2 -d=)


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
	  $extra_cmake_args
    echo_heading "Running Ninja"
    time jhbuild -f $JHBUILDRC -m $JHBUILD_MODULES run ninja -j$num_cores
else
    echo_warning "WARNING!! Incremental rebuild ($build_dir)"

    time jhbuild -f $JHBUILDRC -m $JHBUILD_MODULES run \
	 cmake --build $build_dir \
         --config $build_type -- -j$num_cores bin/MiniBrowser
fi

echo_heading "Clearing caches..."

rm -rf ~/.local/share/rr

echo_heading "Installing built product..."

jhbuild -f $JHBUILDRC -m $JHBUILD_MODULES run ninja -C $build_dir install

popd 2>&1>/dev/null

if test "$build_app"; then
    echo_heading "Building with $port:$branch in configuration $build_type"
    libdir=$install_prefix/lib
    echo "yes webkit-playgroud.c $libdir"
    test ! -e $libdir && echo "installed product has no libdir" && exit 1
    test ! -e $libdir/pkgconfig && echo "installed product has no pkgconfig" && exit 1
    cflags=$(jhbuild -f $JHBUILDRC -m $JHBUILD_MODULES run env \
                     PKG_CONFIG_PATH=$libdir/pkgconfig:$PKG_CONFIG_PATH \
                     pkg-config --cflags gtk+-3.0 webkit2gtk-4.0 gstreamer-1.0)
    libs=$(jhbuild -f $JHBUILDRC -m $JHBUILD_MODULES run env \
                     PKG_CONFIG_PATH=$libdir/pkgconfig:$PKG_CONFIG_PATH \
                     pkg-config --libs gtk+-3.0 webkit2gtk-4.0 gstreamer-1.0)
    $CC -g -O0 -fno-omit-frame-pointer $cflags $build_app -o webkit-playground $libs
fi

if test "$run_app"; then
    echo_heading "Running with $port:$branch in configuration $build_type"
    libdir=$install_prefix/lib
    test ! -e $libdir && echo "installed product has no libdir" && exit 1
    jhbuild -f $JHBUILDRC -m $JHBUILD_MODULES run env \
            LD_LIBRARY_PATH=$libdir:$LD_LIBRARY_PATH \
            $run_app
fi

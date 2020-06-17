#!/bin/bash
# Convert this fucking shit python crap to shell FUCK FUCK FUCK

D=$(dirname $(readlink -f $0))
source $D/common.sh

DEBUGGING=1
usage() {
    echo_heading "$0 <command>"
}

dec() {
    if test $DEBUGGING; then
        echo $@
    fi
}

num_cpus=$(ls -ld /sys/devices/system/cpu/cpu[0-9]* | wc -l)
dec $num_cpus

systemctl is-active iceccd.service 2>&1>/dev/null
# still not a good test, what if i'm on wifi? the service still runs even when you're not on the same subnet as the scheduler... need a little tool to ping the scheduler.
# static ip the scheduler see if it's UP? Who knows, for now all the CPU logic is basically hardcoded.
has_icecream=$?

if test $num_cpus -gt 10; then
    num_background_cpus=$(expr $num_cpus / 2)
elif test $num_cpus -gt 2; then
    num_background_cpus=$(expr \( $num_cpus / 4 \) + 1)
else
    num_background_cpus=1
fi

dec $num_background_cpus
num_background_cpus=50

TLD=~/devenv
SRCDIR=$TLD/sources
SYSROOT=$TLD/sysroot
LOGDIR=$TLD/logs

dec top-level $TLD srcdir $SRCDIR sysroot $SYSROOT

# dependency graph for built projects
# z3
# llvm <- z3
# ccls <- llvm

build_z3() {
    echo_heading "building z3"
    srcdir=$SRCDIR/z3
    builddir=$srcdir/build
    srcurl='https://github.com/Z3Prover/z3.git'
    project_id='z3'
    revision=$(git -C $srcdir rev-parse master)
    if test ! -d $srcdir; then
        git clone $srcurl $srcdir
    fi

    
    export CXX=/usr/lib/icecc/bin/g++
    export CC=/usr/lib/icecc/bin/gcc
    export LD_LIBRARY_PATH="$SYSROOT/lib:$LD_LIBRARY_PATH"

    cmake \
        -Wno-dev \
        -S $srcdir \
        -B $builddir \
        -G Ninja \
        -DCMAKE_INSTALL_PREFIX=$SYSROOT \
        -DCMAKE_PREFIX_PATH=$SYSROOT \
        -DCMAKE_BUILD_TYPE=Release 2>&1 | \
        tee $LOGDIR/configure_$project_id.log

    ninja -C $builddir -l $num_background_cpus | \
        tee $LOGDIR/build_$project_id.log
    ninja -C $builddir -l $num_background_cpus install | \
        tee $LOGDIR/install_$project_id.log
    dec $revision

    enter $SYSROOT
    ostree --repo=$SYSROOT commit  --branch=master -s $project_id \
           --add-metadata="version=\"$revision\""
    leave
}

build_llvm() {
    srcdir="$SRCDIR/llvm-project/llvm"
    builddir="$SRCDIR/llvm-project/build"
    project_id="llvm"
    # FIXME: This is more complicated to clone cos submodules (clang-project)
    if test ! -d $srcdir; then
        echo_error "you need to checkout llvm and clang"
        exit 1
    fi
    revision=$(git -C $srcdir rev-parse master)

    # FIXME: Use a release of LLVM or something, building git is madness Jun2020

    export CXX=/usr/lib/icecc/bin/g++
    export CC=/usr/lib/icecc/bin/gcc
    export LD_LIBRARY_PATH="$SYSROOT/lib:$LD_LIBRARY_PATH"

    cmake \
        -Wno-dev \
        -S $srcdir \
        -B $builddir \
        -G Ninja \
        -DCMAKE_INSTALL_PREFIX=$SYSROOT \
        -DCMAKE_PREFIX_PATH=$SYSROOT \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;libcxx;libcxxabi;libunwind;lldb;compiler-rt;lld;polly;openmp;libc;libclc" \
        -DLLVM_TARGETS_TO_BUILD=X86 \
        2>&1 | \
        tee $LOGDIR/configure_$project_id.log

    ninja -C $builddir -l $num_background_cpus | \
        tee $LOGDIR/build_$project_id.log
    ninja -C $builddir -l $num_background_cpus install | \
        tee $LOGDIR/install_$project_id.log
    dec $revision

    enter $SYSROOT
    ostree --repo=$SYSROOT commit  --branch=master -s $project_id \
           --add-metadata="version=\"$revision\""
    leave
}

build_glib() {
    srcdir="$SRCDIR/glib"
    project_id="glib"
    srcurl='https://gitlab.gnome.org/GNOME/glib.git'
    if test ! -d $srcdir; then
        git clone $srcurl $srcdir
    fi
    revision=$(git -C $srcdir rev-parse master)

    export CXX=/usr/lib/icecc/bin/g++
    export CC=/usr/lib/icecc/bin/gcc
    export LD_LIBRARY_PATH="$SYSROOT/lib:$LD_LIBRARY_PATH"

    enter $srcdir
    meson --prefix=$SYSROOT build
    ninja -l $num_background_cpus | \
        tee $LOGDIR/build_$project_id.log
    ninja -C build -l $num_background_cpus install | \
        tee $LOGDIR/install_$project_id.log
    dec $revision

    enter $SYSROOT
    ostree --repo=$SYSROOT commit  --branch=master -s $project_id \
           --add-metadata="version=\"$revision\""
    leave
}

build_cairo() {
    srcdir="$SRCDIR/cairo"
    project_id="cairo"
    srcurl='https://gitlab.freedesktop.org/cairo/cairo.git'
    if test ! -d $srcdir; then
        git clone $srcurl $srcdir
    fi
    revision=$(git -C $srcdir rev-parse master)

    export CXX=/usr/lib/icecc/bin/g++
    export CC=/usr/lib/icecc/bin/gcc
    export LD_LIBRARY_PATH="$SYSROOT/lib:$LD_LIBRARY_PATH"
    export PKG_CONFIG_PATH="$SYSROOT/lib/x86_64-linux-gnu/pkgconfig/:$PKG_CONFIG_PATH" \

    enter $srcdir
    echo $PWD
    echo meson --prefix=$SYSROOT build
    exit 1
    ninja -l $num_background_cpus | \
        tee $LOGDIR/build_$project_id.log
    if test $? -ne 0 ;then
        echo_error "build failed"
        exit 1
    fi

    ninja -C build -l $num_background_cpus install | \
        tee $LOGDIR/install_$project_id.log
    if test $? -ne 0 ;then
        echo_error "install failed"
        exit 1
    fi

    enter $SYSROOT
    ostree --repo=$SYSROOT commit  --branch=master -s $project_id \
           --add-metadata="version=\"$revision\""
    leave
}


build_pango() {
    srcdir="$SRCDIR/pango"
    project_id="pango"
    srcurl='https://gitlab.gnome.org/GNOME/pango.git'
    if test ! -d $srcdir; then
        git clone $srcurl $srcdir
    fi
    revision=$(git -C $srcdir rev-parse master)

    export CXX=/usr/lib/icecc/bin/g++
    export CC=/usr/lib/icecc/bin/gcc
    export LD_LIBRARY_PATH="$SYSROOT/lib:$LD_LIBRARY_PATH"
    export PKG_CONFIG_PATH="$SYSROOT/lib/x86_64-linux-gnu/pkgconfig/:$PKG_CONFIG_PATH" \

    enter $srcdir
    meson --prefix=$SYSROOT build
    ninja -l $num_background_cpus | \
        tee $LOGDIR/build_$project_id.log
    if test $? -ne 0 ;then
        echo_error "build failed"
        exit 1
    fi

    ninja -C build -l $num_background_cpus install | \
        tee $LOGDIR/install_$project_id.log
    if test $? -ne 0 ;then
        echo_error "install failed"
        exit 1
    fi

    enter $SYSROOT
    ostree --repo=$SYSROOT commit  --branch=master -s $project_id \
           --add-metadata="version=\"$revision\""
    leave
}


build_gtk() {
    srcdir="$SRCDIR/gtk"
    project_id="gtk"
    srcurl='https://gitlab.gnome.org/GNOME/gtk.git'
    if test ! -d $srcdir; then
        git clone $srcurl $srcdir
    fi
    revision=$(git -C $srcdir rev-parse master)

    export CXX=/usr/lib/icecc/bin/g++
    export CC=/usr/lib/icecc/bin/gcc
    export LD_LIBRARY_PATH="$SYSROOT/lib:$LD_LIBRARY_PATH"
    export PKG_CONFIG_PATH="$SYSROOT/lib/x86_64-linux-gnu/pkgconfig/:$PKG_CONFIG_PATH" \

    enter $srcdir
    meson --prefix=$SYSROOT build
    ninja -l $num_background_cpus | \
        tee $LOGDIR/build_$project_id.log
    if test $? -ne 0 ;then
        echo_error "build failed"
        exit 1
    fi

    ninja -C build -l $num_background_cpus install | \
        tee $LOGDIR/install_$project_id.log
    if test $? -ne 0 ;then
        echo_error "install failed"
        exit 1
    fi

    enter $SYSROOT
    ostree --repo=$SYSROOT commit  --branch=master -s $project_id \
           --add-metadata="version=\"$revision\""
    leave
}

build_epiphany() {
    srcdir="$SRCDIR/epiphany"
    project_id="epiphany"
    srcurl='https://gitlab.gnome.org/GNOME/epiphany.git'
    if test ! -d $srcdir; then
        git clone $srcurl $srcdir
    fi
    revision=$(git -C $srcdir rev-parse master)

    export CXX=/usr/lib/icecc/bin/g++
    export CC=/usr/lib/icecc/bin/gcc
    export LD_LIBRARY_PATH="$SYSROOT/lib:$LD_LIBRARY_PATH"
    export PKG_CONFIG_PATH="$SYSROOT/lib/x86_64-linux-gnu/pkgconfig/:$PKG_CONFIG_PATH" \

    enter $srcdir
    meson --prefix=$SYSROOT build
    ninja -l $num_background_cpus | \
        tee $LOGDIR/build_$project_id.log
    if test $? -ne 0 ;then
        echo_error "build failed"
        exit 1
    fi

    ninja -C build -l $num_background_cpus install | \
        tee $LOGDIR/install_$project_id.log
    if test $? -ne 0 ;then
        echo_error "install failed"
        exit 1
    fi

    enter $SYSROOT
    ostree --repo=$SYSROOT commit  --branch=master -s $project_id \
           --add-metadata="version=\"$revision\""
    leave
}

dec "num arguments: $#"
if test $# -eq 0; then
    usage
    exit 1
fi

cmd=$1

if test $cmd = "run"; then
    shift
    # FIXME: icecc should have options that allow it to tell when compiltation is worth it
    #  i.e., not when you're connected to wifi, and when the scheduler is actually online
    env \
        CXX=/usr/lib/icecc/bin/g++ \
        CC=/usr/lib/icecc/bin/gcc \
        LD_LIBRARY_PATH="$SYSROOT/lib:$LD_LIBRARY_PATH" \
        PKG_CONFIG_PATH="$SYSROOT/lib/x86_64-linux-gnu/pkgconfig/:$PKG_CONFIG_PATH" \
        $@
else
    eval $cmd
fi    



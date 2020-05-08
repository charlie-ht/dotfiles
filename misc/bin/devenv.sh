#!/bin/bash
# Convert this fucking shit python crap to shell FUCK FUCK FUCK

D=$(dirname $(readlink -f $0))
source $D/common.sh

DEBUGGING=
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

if test $num_cpus -gt 10; then
    num_background_cpus=$(expr $num_cpus / 2)
elif test $num_cpus -gt 2; then
    num_background_cpus=$(expr \( $num_cpus / 4 \) + 1)
else
    num_background_cpus=1
fi
dec $num_background_cpus

TLD=~/devenv
SRCDIR=$TLD/sources
SYSROOT=$TLD/sysroot
LOGDIR=$TLD/logs

dec top-level $TLD srcdir $SRCDIR sysroot $SYSROOT

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
    env \
        CXX=/usr/lib/icecc/bin/clang++ \
        CC=/usr/lib/icecc/bin/clang \
        LD_LIBRARY_PATH="$SYSROOT/lib:$LD_LIBRARY_PATH" \
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


dec $#
if test $# -eq 0; then
    usage
    exit 1
fi

cmd=$1

if test $cmd = "run"; then
    shift
    env \
        CXX=/usr/lib/icecc/bin/clang++ \
        CC=/usr/lib/icecc/bin/clang \
        LD_LIBRARY_PATH="$SYSROOT/lib:$LD_LIBRARY_PATH" \
        $@
else
    eval $cmd
fi    



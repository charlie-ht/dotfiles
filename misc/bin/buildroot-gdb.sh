#!/bin/bash

export BUILDROOT=$HOME/buildroot/buildroot-2019.02.2
export OUTPUT_DIR=$BUILDROOT/output_wpe_64
export TARGET_DIR=${OUTPUT_DIR}/target
export STAGING_DIR=${OUTPUT_DIR}/staging

export SYSROOT="${OUTPUT_DIR}/host/aarch64-buildroot-linux-gnu/sysroot"
GDB="${OUTPUT_DIR}/host/usr/bin/aarch64-buildroot-linux-gnu-gdb"

SOURCE_PATH=${OUTPUT_DIR}/build/cog-063df115456a24e464d1e6f284df22a0e65aea8e/:${OUTPUT_DIR}/build/wpewebkit-custom/Source/JavaScriptCore:${OUTPUT_DIR}/build/wpewebkit-custom/Source/

SOURCE_COMMAND="directory ${SOURCE_PATH}"

#file $GDB
#echo $SOURCE_COMMAND

PROCESS=cog
CORE_FILE=core.dump

rm -f /tmp/gdbscript
cat >> /tmp/gdbscript << EOF
set sysroot ${SYSROOT}
${SOURCE_COMMAND}
set demangle-style none
set detach-on-fork off
set follow-fork-mode child
set pagination off
set breakpoint pending on
exec-file ${PROCESS}
core-file ${CORE_FILE}
info sharedlibrary
set logging redirect on
set logging file /tmp/dump.log
thread apply all bt
EOF

cd $OUTPUT_DIR/build/cog-063df115456a24e464d1e6f284df22a0e65aea8e/
cat /tmp/gdbscript
$GDB -x /tmp/gdbscript

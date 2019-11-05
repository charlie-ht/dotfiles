#!/bin/bash

D=$(dirname $(readlink -f $0))
source $D/common.sh

PID=$(ps -ef | grep WebKitWebProcess | grep -v grep | grep 'home/cturner' | awk '{print $2}')
if [[ -z $PID ]] ; then
    echo_error "could not find the WebProcess"
    exit 1
fi

echo_heading "Attaching to $PID"
echo_heading "This may take a few minutes for WebKit, reading symbols from shared libraries"

cat <<EOF > /tmp/volume_bug.gdb
# http://sourceware.org/gdb/wiki/FAQ: to disable the
# "---Type <return> to continue, or q <return> to quit---"
# in batch mode:
set width 0
set height 0
set verbose off
set breakpoint pending on
set print thread-events off


break MediaSource.cpp:631
commands
  silent
  printf "MediaSource streamEndedWithError"
  bt 10
  cont
end

dprintf MediaPlayerPrivateGStreamerMSE::markEndOfStream,"MediaPlayerPrivateGStreamerMSE::markEndOfStream"
#dprintf gst_play_sink_set_volume,"playsink set volume %g\n",volume
#dprintf gstplaysink.c:2657,"playsink notify volume cb %g\n",vol
#dprintf MediaPlayer.cpp:774,"MediaPlayer volume is %g\n",m_volume
#dprintf MediaPlayer.cpp:782,"MediaPlayer volume set to %g\n",volume
#break MediaPlayer.cpp:782
#commands
#  silent
#  printf "MediaPlayer volume set to %g\n",volume
#  bt 10
#  cont
#end

continue
EOF

gdb -p $PID --batch --command=/tmp/volume_bug.gdb

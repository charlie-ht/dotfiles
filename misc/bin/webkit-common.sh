GSTREAMER_ROOT=$HOME/gstreamer/gst-build

if [[ -z $GST_ENV ]]; then
    echo_warning "Not in a gst-environment, setting that up now"
    eval $($GSTREAMER_ROOT/gst-env.py --only-environment)
fi

if [ $(hostname) == "cnut" ]; then
    NUM_CORES=28
elif [ $(hostname) == "deimos" ]; then
    # FIXME: How do I detect if Icecream is available? Need to tone this down when on the the road.
    #    I'll just assume it's there...
    NUM_CORES=40
elif [ $(hostname) == "hp-laptop" ]; then
    NUM_CORES=3
else
    echo_warning "Unknown host, default to 4 cores"
    NUM_CORES=4
fi

JHBUILDRC=$HOME/igalia/sources/webkit-misc/jhbuildrc
JHBUILD_MODULES=$HOME/igalia/sources/webkit-misc/jhbuild.modules
src_dir=$HOME/igalia/sources/WebKit

check_branch() {
    if test -z "$branch"; then
        branch=$(git -C $src_dir rev-parse --abbrev-ref HEAD | sed -e 's/[^A-Za-z0-9._-]/_/g')
    fi
}

normalize_branch() {
    branch=$(echo $branch | sed -e 's/[^A-Za-z0-9._-]/_/g')
}

pathmunge ()
{
    if ! echo "$PATH" | /bin/grep -Eq "(^|:)$1($|:)" ; then
        if [ "$2" = "after" ] ; then
            PATH="$PATH:$1"
        else
            PATH="$1:$PATH"
        fi
    fi
}
path_prepend_if_missing ()
{
    local pathname="$1"
    if [ -d $pathname ]; then
        pathmunge $pathname
    fi
}

WEBKIT_EVENTS=Events,PlatformLeaks
WEBKIT_NETWORK_CHANNELS=Network,NetworkCache,NetworkCacheSpeculativePreloading,NetworkCacheStorage,NetworkScheduling,NetworkSession,Loading,LocalStorageDatabaseTracker,ProximityNetworking,ResourceLoadStatistics,Storage,ContentFiltering,ResourceLoading,ResourceLoadObserver,ResourceLoadStatistics
WEBKIT_MEDIA_CHANNELS=Fullscreen,Media,WebRTC,Images,MediaCaptureSamples,MediaQueries,MediaSource,MediaStream,MediaSourceSamples,WebAudio,WebGPU,WebRTCStats,EME
WEBKIT_IPC=IPC,Process,ProcessSuspension,ProcessSwapping,MessagePorts
WEBKIT_PERF=VirtualMemory,VisibleRects,WebGL,Animations,Compositing,CompositingOverlap,MemoryPressure,PerformanceLogging,SVG,Tiling,Threading

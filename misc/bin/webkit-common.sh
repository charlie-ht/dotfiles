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

JHBUILDRC=$HOME/webkit/webkit-misc/jhbuildrc
JHBUILD_MODULES=$HOME/webkit/webkit-misc/jhbuild.modules
src_dir=$HOME/webkit/WebKit

check_branch() {
    if test -z "$branch"; then
        branch=$(git -C $src_dir rev-parse --abbrev-ref HEAD | sed -e 's/[^A-Za-z0-9._-]/_/g')
    fi
}

normalize_branch() {
    branch=$(echo $branch | sed -e 's/[^A-Za-z0-9._-]/_/g')
}

WEBKIT_EVENTS=Events,PlatformLeaks
WEBKIT_NETWORK_CHANNELS=Network,NetworkCache,NetworkCacheSpeculativePreloading,NetworkCacheStorage,NetworkScheduling,NetworkSession,Loading,LocalStorageDatabaseTracker,ProximityNetworking,ResourceLoadStatistics,Storage,ContentFiltering,ResourceLoading,ResourceLoadObserver,ResourceLoadStatistics
WEBKIT_MEDIA_CHANNELS=Fullscreen,Media,WebRTC,Images,MediaCaptureSamples,MediaQueries,MediaSource,MediaStream,MediaSourceSamples,WebAudio,WebGPU,WebRTCStats,EME
WEBKIT_IPC=IPC,Process,ProcessSuspension,ProcessSwapping,MessagePorts
WEBKIT_PERF=VirtualMemory,VisibleRects,WebGL,Animations,Compositing,CompositingOverlap,MemoryPressure,PerformanceLogging,SVG,Tiling,Threading

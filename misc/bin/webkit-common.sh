if [[ -z $GST_ENV || $GST_ENV -ne "gst-master" ]]; then
    echo "Not in a gst-master uninstalled environment, aborting!"
    exit 1
fi

if [ $(hostname) == "cnut" ]; then
    NUM_CORES=28
elif [ $(hostname) == "h1n1" ]; then
    # FIXME: How do I detect if Icecream is available? Need to tone this down when on the the road.
    NUM_CORES=12
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


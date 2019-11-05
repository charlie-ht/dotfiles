function echo_error() {
    RED='\033[0;31m'
    NC='\033[0m' # No Color
    printf "\n${RED}....$1${NC}\n"
}
function echo_heading() {
    GREEN='\033[0;32m'
    NC='\033[0m' # No Color
    printf "\n${GREEN}....$1${NC}\n"
}
function echo_warning() {
    YELLOW='\033[0;33m'
    NC='\033[0m' # No Color
    printf "\n${YELLOW}....$1${NC}\n"
}

if [[ -z $GST_ENV || $GST_ENV -ne "gst-master" ]]; then
    echo "Not in a gst-master uninstalled environment, aborting!"
    exit 1
fi

if [ $(hostname) == "buildmachine" ]; then
    NUM_CORES=28
elif [ $(hostname) == "h1n1" ]; then
    # FIXME: How do I detect if Icecream is available? Need to tone this down when on the the road.
    NUM_CORES=12
else
    echo_warning "Unknown host, default to 4 cores"
    NUM_CORES=4
fi

JHBUILDRC=$HOME/webkit/jhbuildrc
JHBUILD_MODULES=$HOME/webkit/jhbuild.modules

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

enter(){
    pushd $1 2>&1>/dev/null
}
leave(){
    popd
}

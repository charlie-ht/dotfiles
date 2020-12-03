export CDPATH=$CDPATH:$HOME/igalia/graphics/

function mesa_grep_ci() {
    grep -rn "$@" $HOME/src/mesa/.gitl* | grep -v :0
}

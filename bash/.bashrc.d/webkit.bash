alias c_wk_test_results='x-www-browser file://$HOME/webkit-test/results.html'

export WK_SOURCE_DIR=$HOME/igalia/sources/WebKit

c_wk_enter() {
    gst_env=$($HOME/gstreamer/gst-build/gst-env.py --only-environment)
    >/tmp/bashrc
    cat ~/.bashrc >> /tmp/bashrc
    cat <<EOF >> /tmp/bashrc

$gst_env

export PS1="[webkit] $PS1"
export WEBKIT_SRC=$WK_SOURCE_DIR
export PATH=\$PATH:\$WEBKIT_SRC/Tools/Scripts

cd \$WEBKIT_SRC
git status
ulimit -c unlimited
EOF

    bash --rcfile /tmp/bashrc
}


c_wk_grep_expectations () {
    find $WK_SOURCE_DIR/LayoutTests -name "TestExpectations" | xargs grep -rn $@
}

c_gst_plugins() {
    plugin_name=$1
    IFS=:
    for path in $GST_PLUGIN_PATH ; do
	if [ -d $path ] ; then
	    find $path -name "*$plugin_name*"
	fi
    done
}

rg_gst()
{
    if [[ $PWD == $HOME/gstreamer/gst-build ]]; then
        rg -g "*.c" -g "*.h" -L $@ subprojects/* 
    fi
}

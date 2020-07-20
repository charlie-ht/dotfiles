export BR_OUTPUT_DIR=$HOME/igalia/buildroot/output
alias c_br_list_configs='make list-defconfigs'
alias c_br_full_rebuild='make clean all'
alias c_br_configure_busybox='make busybox-menuconfig'
alias c_br_configure_linux='make linux-menuconfig'
alias c_br_serial_rpi3='sudo picocom -b 115200 /dev/ttyUSB0'

c_br_rebuild_pkg ()
{
    local pkg=$1
    make ${pkg}_dirclean ${pkg}
}
c_br_ccache_set_max_size () {
    local limit=$1
    make CCACHE_OPTIONS="--max-size=${limit}" ccache-options
}
c_br_ccache_zero_stats () {
    make CCACHE_OPTIONS="--zero-stats" ccache-options
}

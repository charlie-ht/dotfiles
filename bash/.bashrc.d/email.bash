c_igalia_db () {
    command=$1
    shift
    notmuch $command 'path:igalia/**' and $@
}

c_gmail_db () {
    command=$1
    shift
    notmuch $command 'path:chturne_gmail/**' and $@
}

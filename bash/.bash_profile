if [ -s /etc/profile ]; then
    source /etc/profile
fi

if [ -f ~/.bashrc ]; then
    source ~/.bashrc;
fi

pathmunge () {
        if ! echo "$PATH" | /bin/grep -Eq "(^|:)$1($|:)" ; then
           if [ "$2" = "after" ] ; then
              PATH="$PATH:$1"
           else
              PATH="$1:$PATH"
           fi
        fi
}

export EDITOR='emacsclient'
export PAGER=less

path_append_if_missing()
{
    local pathname="$1"
    if [ -d $pathname ]; then
        pathmunge $pathname
    fi
}

path_append_if_missing $HOME/bin
path_append_if_missing $HOME/.local/bin
path_append_if_missing $HOME/.cargo/bin
path_append_if_missing $HOME/Bento4-SDK-1-5-1-629.x86_64-unknown-linux/bin

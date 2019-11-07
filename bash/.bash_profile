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

if [ -d $HOME/bin ]; then
    pathmunge $HOME/bin
fi

if [ -d $HOME/.local/bin ]; then
	pathmunge $HOME/.local/bin
fi

if [ -d $HOME/.cargo/bin ]; then
    pathmunge $HOME/.cargo/bin
fi

# If icecc is installed, make sure it's the root of the path
if [ -d /usr/lib/icecc/bin ]; then
	pathmunge /usr/lib/icecc/bin
     # ccache must precede icecc (https://bugzilla.redhat.com/show_bug.cgi?id=377761)
     if [ -d /usr/lib/ccache ]; then
	     pathmunge /usr/lib/ccache
     fi
fi

if [ -s /etc/profile ]; then
    source /etc/profile
fi

if [ -d $HOME/bin ]; then
    export PATH="$HOME/bin:$PATH"
fi

export EDITOR='emacsclient'
export PAGER=less
export GITHUB_USER=charlie-ht

if command -v go 2>&1>/dev/null ; then
    export GOPATH=$HOME/go
    export PATH=$PATH:$(go env GOPATH)/bin
    export GO_GITHUB=github.com/$GITHUB_USER
    export GO_GITHUB_PATH=$GOPATH/src/$GO_GITHUB
fi

if [ -f ~/.bashrc ]; then
    source ~/.bashrc;
fi

if [[ -e $HOME/local/Bento4-SDK-1-5-1-621.x86_64-unknown-linux/bin ]]; then
    PATH="$HOME/local/Bento4-SDK-1-5-1-621.x86_64-unknown-linux/bin:$PATH"
fi

if [[ -e $HOME/.local/bin ]]; then
	PATH=$HOME/.local/bin:$PATH
fi

if [[ -e $HOME/.cargo/bin ]]; then
    PATH=$HOME/.cargo/bin:$PATH
fi

# If icecc is installed, make sure it's the root of the path
if [[ -d /usr/lib/icecc/bin ]]; then
    PATH="/usr/lib/icecc/bin:$PATH"
     # ccache must precede icecc (https://bugzilla.redhat.com/show_bug.cgi?id=377761)
     if [[ -d /usr/lib/ccache ]]; then
 	PATH="/usr/lib/ccache:$PATH"
     fi
fi

export PATH="$HOME/.cargo/bin:$PATH"

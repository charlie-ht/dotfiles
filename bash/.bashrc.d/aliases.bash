if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls -h --color=auto'
    alias ll='ls --color=auto -ltrh'
fi

alias e='emacsclient -n'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias mkdir='mkdir -pv'
if [ -x $(which pydf) ]; then
    alias df=pydf
fi
alias dir_size='du -sh'

alias path="echo $PATH | tr ':' '\n'"
alias pypath="echo $PYTHONPATH | tr ':' '\n'"

alias wget='wget -c'
alias myip='curl http://ipecho.net/plain; echo'
alias myps='ps -U $(whoami) -u $(whoami) u'
alias sprunge="curl -F 'sprunge=<-' http://sprunge.us"

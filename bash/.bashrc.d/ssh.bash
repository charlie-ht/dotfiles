 #https://unix.stackexchange.com/questions/90853/how-can-i-run-ssh-add-automatically-without-password-prompt
 if [ -z "$SSH_AUTH_SOCK" ] ; then
     { eval `ssh-agent -s` ; ssh-add ; } &>/dev/null
 fi

 trap 'test -n "$SSH_AUTH_SOCK" && eval `/usr/bin/ssh-agent -k` &> /dev/null' 0

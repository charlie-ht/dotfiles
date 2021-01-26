if [ "$SSH_CONNECTION" ] && pgrep ssh-agent &> /dev/null 2>&1 ; then
    echo "WARNING: You are in a SSH hurt locker!!!"
    echo "WARNING: You are forwarding an SSH agent, yet their is an agent already running on this server"
    echo "WARNING: That will only lead to doom"
    echo "The agent on this host has PID $(pgrep ssh-agent)"
    echo "Try making it stop starting up!"
fi

# Only start keychain on machines we have not SSH'd to.
# For those that we have SSH'd, SSH agent-forwarding should be all
# that is needed.
[ "$SSH_CONNECTION" ] || eval `keychain --eval --agents ssh id_rsa_charlie id_ed25519_charlie id_rsa_igalia`

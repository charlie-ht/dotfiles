# Only start keychain on machines we have not SSH'd to.
# For those that we have SSH'd, SSH agent-forwarding should be all
# that is needed.
[ "$SSH_CONNECTION" ] || eval `keychain --eval --agents ssh id_rsa_charlie id_ed25519_charlie id_rsa_igalia`

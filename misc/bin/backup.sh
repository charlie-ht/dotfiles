#!/bin/bash

D=$(dirname $(readlink -f $0))
source $D/common.sh

rsync_dry_run='-n'

while test -n "$1"; do
    case "$1" in
        --write)
            rsync_dry_run=''
            ;;
        *)
            passthru="$passthru $1"
            ;;
    esac
    shift
done


MOUNT=/media/cht/Backup

if ! test -d $MOUNT; then
    echo_error "$MOUNT does not exist"
    exit 1
fi

echo_heading "Backing up to mount point $MOUNT"

cat <<EOF | rsync -av $rsync_dry_run --delete --delete-excluded  --stats --human-readable --filter='. -' $HOME/ "$MOUNT/rsync" | tee $HOME/logs/backup-$(date +%Y-%M-%d).log
# Per-directory overrides.
# : .rsync-excludes

# Selectively include dotfiles
+ .bash_history
+ .bash_logout
+ .bash_profile
+ .bashrc
+ .config
+ .emacs
+ .gitconfig
+ .gnupg
+ .gtk-bookmarks
+ .local
+ .mozilla
+ .npm
+ .password-store
+ .pki
+ .profile
+ .saves
+ .ssh
+ .steam
+ .steampath
+ .steampid
+ .subversion
+ .tmux.conf
+ .var
+ .vim
+ .viminfo
+ .vimrc
+ .wget-hsts
+ .xchm
+ .Xresources
+ .Xresources.d
# Make sure this stays as the last thing after the explicit includes.
- /.*

# Selectively exclude files
- /Downloads
- /scratch
- *.pyc
- *~
- *.swp
- *#*
- *ccache*
- Qt/
- /webkit/build*/
- /webkit/deps*/
- /igalia/metro/poky/
- /buildroot/**/dl/
- /buildroot/**/output*/
- /buildroot/**/ccache/
EOF

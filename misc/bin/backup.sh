#!/bin/bash

D=$(dirname $(readlink -f $0))
source $D/common.sh

# These are the steps to mirror the apt status, I don't know a good way of automating this.
# computer1$ apt-clone clone cnut.clone
# scp cnut.clone* computer2
# computer2$ sudo apt-clone restore cnut.clone*
# And now you should have the same sets of packages.

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

cat <<EOF | rsync -av $rsync_dry_run --delete --delete-excluded  --stats --human-readable --filter='. -' $HOME/ "$MOUNT/rsync" | tee $HOME/logs/backup-$(date +%Y-%m-%d-%H%M%S).log
# Per-directory overrides.
# : .rsync-excludes

# Selectively include dotfiles
+ .Xresources
+ .Xresources.d
+ .bash_history
+ .bash_logout
+ .bash_profile
+ .bashrc
+ .config
+ .emacs
+ .getmail
+ .gitconfig
+ .gnupg
+ .gtk-bookmarks
+ .local
+ .mozilla
+ .npm
+ .password-store
+ .pki
+ .profile
+ .reportbugrc
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
- .local/share/
- .config/google-chrome/
# Make sure this stays as the last thing after the explicit includes.
- /.*

# Selectively exclude files
- /Downloads
- /scratch
- .ccls-cache/
- *.pyc
- *~
- *.swp
- *#*
- Qt/
- /webkit/build*/
- /webkit/deps*/
- /igalia/metrological/yocto/**/*build*/cache
- /igalia/metrological/yocto/**/*build*/tmp-glibc
- /igalia/metrological/yocto/**/*build*/sstate*
- /**/buildroot*/dl/
- /**/buildroot*/output/
- /igalia/webkit-build-*/
- /webkit-test/
- /cores/
# Recreatable
- /devenv/
- /igalia/jhbuild-deps-prefix/
- /gstreamer/gst-build/build/
- /arm-buildroot-linux-gnueabihf_sdk-buildroot/
- /local

EOF

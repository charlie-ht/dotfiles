#!/bin/bash

# Set errexit to force an exit on error conditions, and pipefail to
# force any failures in a pipeline to create an error condition
set -o errexit
set -o pipefail
#set -o xtrace


D=$(dirname $(readlink -f $0))
source $D/common.sh

# Would be nice to be not reliant on the DE setting up the disk
# mkdir /tmp/backup-mountpoint
# sudo cryptsetup luksOpen /dev/sda1 cryptbackup || exit 1
# sudo mount /dev/mapper/cryptbackup /tmp/backup-mountpoint || exit 1
# trap cleanup EXIT SIGINT
# cleanup() {
# 	sudo umount /tmp/backup-mountpoint
# 	sudo cryptsetup close cryptbackup
# 	rm -rf /tmp/backup-mountpoint
# }

MOUNT=/media/cht/Backup
LOG_FILE=/tmp/backup-$(date +%Y-%m-%d-%H%M).log
DRY_RUN='yes'

log() {
    echo_heading "$LOG_PREFIX $@" | tee -a $LOG_FILE
}

backup()
{
    set -o nounset

    log "Backing up to mount point $MOUNT."
    log "Logging to $LOG_FILE."

    log "Backing up installed package list..."
    selections=$(dpkg --get-selections | grep -v deinstall)
    num_selections=$(dpkg --get-selections | grep -v deinstall | wc -l)
    log "There are $num_selections packages."
    [ "$DRY_RUN" ] || echo $selections > $MOUNT/ubuntu-packages.list

    log "Backing up /usr/local"
    [ "$DRY_RUN" ] || tar cf "$MOUNT/usrlocal.tar" /usr/local

    log "(!!ROOT REQUIRED!!) Backing up /etc"
    [ "$DRY_RUN" ] || sudo tar cf "$MOUNT/etc.tar" /etc

    log "Backing up $HOME"
    cat <<EOF | rsync -av $RSYNC_EXTRA --delete --delete-excluded  --stats --human-readable --filter='. -' $HOME/ "$MOUNT/rsync" | tee -a $LOG_FILE
# Per-directory overrides.
# : .rsync-excludes

# Selectively include dotfiles
+ .X*
+ .bash_history
+ .bash_logout
+ .bash_profile
+ .bashrc
+ .bashrc.d
+ .config
# This is all saved in the Chrome cloud anyway, and there's a lot of crap
- .config/google-chrome/
# Also not interesting configuration
- .config/discord/
+ .docker
+ .emacs
+ .getmail
+ .gitconfig
+ .gnupg
+ .gtk-bookmarks
+ .mozilla
+ .npm
+ .password-store
+ .pki
+ .profile
+ .python-gitlab.cfg
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
+ .virtualenvs/
+ .wget-hsts
+ .x*
+ .xchm

# Make sure this stays as the last thing after the explicit includes.
- /.*

# Selectively exclude files
- *#*
- *.pyc
- .tox/
- *.swp
- *~
- .ccls-cache/
- /**/buildroot*/dl/
- /**/buildroot*/output/
- /Downloads
- /remotes
- /scratch
- Qt/
- local/
EOF
    set +o nounset
}

restore()
{
    exit 1
}

usage()
{
    echo "$0 -f will perform writes, by default show actions to be taken"
}

while test -n "$1"; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -f)
            DRY_RUN=
            ;;
        *)
            echo_error "Unknown option $1"
            exit 1
            ;;
    esac
    shift
done

[ -G $MOUNT/rsync ] || die "$MOUNT does not exist or is not owned by us"
if [ "$DRY_RUN" ]; then
    LOG_PREFIX="(DRY)"
    RSYNC_EXTRA="-n"
else
    LOG_PREFIX="(LIVE)"
    RSYNC_EXTRA=""
fi


backup

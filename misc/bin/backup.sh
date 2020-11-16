#!/bin/bash

D=$(dirname $(readlink -f $0))
source $D/common.sh

# mkdir /tmp/backup-mountpoint
# sudo cryptsetup luksOpen /dev/sda1 cryptbackup || exit 1
# sudo mount /dev/mapper/cryptbackup /tmp/backup-mountpoint || exit 1
# trap cleanup EXIT SIGINT
# cleanup() {
# 	sudo umount /tmp/backup-mountpoint
# 	sudo cryptsetup close cryptbackup
# 	rm -rf /tmp/backup-mountpoint
# }

rsync_dry_run='-n'
MOUNT=/media/cht/Backup
LOG_FILE=/tmp/backup-$(date +%Y-%m-%d-%H%M).log

backup()
{
    echo_heading "Backing up to mount point $MOUNT." | tee -a $LOG_FILE
    echo_heading "Logging to $LOG_FILE." | tee -a $LOG_FILE

    echo_heading "Backing up system files" | tee -a $LOG_FILE
    selections=$(dpkg --get-selections | grep -v deinstall)
    cat <<<$selections | tee -a $LOG_FILE 1>$MOUNT/ubuntu-packages.list

    echo_heading "Backing up /usr/local" | tee -a $LOG_FILE
    sudo tar cf "$MOUNT/usrlocal.tar" /usr/local | tee -a $LOG_FILE

    echo_heading "Backing up /etc" | tee -a $LOG_FILE
    sudo tar cf "$MOUNT/etc.tar" /etc | tee -a $LOG_FILE

    echo_heading "Backing up $HOME" | tee -a $LOG_FILE
    cat <<EOF | rsync -av $rsync_dry_run --delete --delete-excluded  --stats --human-readable --filter='. -' $HOME/ "$MOUNT/rsync" | tee -a $LOG_FILE
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
+ .docker
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

- .config/google-chrome/
- .local/share/

# Make sure this stays as the last thing after the explicit includes.
- /.*

# Selectively exclude files
- *#*
- *.pyc
- *.swp
- *~
- .ccls-cache/
- /**/buildroot*/dl/
- /**/buildroot*/output/
- /Downloads
- /arm-buildroot-linux-gnueabihf_sdk-buildroot/
- /cores/
- /devenv/
- /gstreamer/gst-build/build/
- /igalia/graphics/gfxreconstruct/*build/
- /igalia/graphics/mesa/_build/
- /igalia/jhbuild-deps-prefix/
- /igalia/metrological/yocto/**/*build*/cache
- /igalia/metrological/yocto/**/*build*/sstate*
- /igalia/metrological/yocto/**/*build*/tmp-glibc
- /igalia/webkit-build-*/
- /local
- /remotes
- /scratch
- /webkit-test/
- /webkit/build*/
- /webkit/deps*/
- Qt/

EOF
}

restore()
{
    exit 1
}

usage()
{
    echo "Provision script"
    echo "================"
    echo "Backs up $HOME and system files to a USB drive labelled with a given label (default: Backup)"
    echo "The idea is that restoring from the result of this script will provision a new developer machine"
    echo "with all of my hard-won defaults."
    echo "I use Ubuntu exclusively. This is not because I make any claims about its relative merits, but"
    echo "rather because consistency is king in development. Differences hurt exponentially in their number."
    echo "Options====="
    echo "$0 [GLOBAL_OPTIONS] CMD"
    echo "GLOBAL_OPTIONS"
    echo "--label - label of disk drive to open. Default Backup. This is used as /media/$USER/$LABEL"
    echo "CMD"
    echo "write - by default, the script will not modify anything. You must explicitly pass this option for"
    echo "change to take affect. My backup strategy is destructive. Deleted files get deleted forever. There"
    echo "is no roll-back after backing up."
    echo "read|restore - restore a new system from the connected drive. This must be run as root"
}

while test -n "$1"; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --label=*)
            BACKUP_LABEL="${1#--label=}"
            ;;
        write|backup)
            rsync_dry_run=''
            backup
            exit 0
            ;;
        "read"|restore)
            restore
            exit 0
            ;;
        *)
            # Does this dry
            echo_error "Unknown option $1"
            exit 1
            ;;
    esac
    shift
done

# default is to backup
backup


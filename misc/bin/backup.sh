#!/bin/bash

D=$(dirname $(readlink -f $0))
source $D/common.sh

while test -n "$1"; do
    case "$1" in
        --commit)
            do_commit=1
            ;;
        *)
            passthru="$passthru $1"
            ;;
    esac
    shift
done


TOSHIBA_UUID=0f286a71-0ca3-429e-b973-987ff555004e
PASSPORT_UUID=c788d9de-d012-45d5-9663-2cfe17de9219

MOUNT=$(findmnt -n -S UUID=$PASSPORT_UUID -o TARGET)
if test -n $MOUNT ; then
    MOUNT=$(findmnt -n -S UUID=$TOSHIBI_UUID -o TARGET)
    if test -n $MOUNT; then
	echo_error "Could not find backup mount point"
        exit 1
    else
        echo_heading "Found Toshiba drive at $MOUNT"
    fi
else
    echo_heading "Found Passport drive at $MOUNT"
fi

echo_heading "Backing up to mount point $MOUNT"

if test -n "$do_commit" ; then
    rsync_dry_run='-n'
fi

cat <<EOF | rsync -va $rsync_dry_run --delete --delete-excluded --filter='. -' $HOME/ "$MOUNT/rsync"
# Per-directory overrides.
# : .rsync-excludes

# Selectively include dotfiles
+ .bash_logout
+ .bash_profile
+ .bashrc
+ .gdbinit
+ .gnupg/
+ .ssh/
+ .maildirs/
+ .getmail/
+ .msmtprc
+ .config/user/
+ .password-store/
# Make sure this stays as the last thing after the explicit includes.
- /.*

- /Downloads
- /scratch
- *.pyc
- *~
- *.swp
- *#*
- *ccache*
- WebKitBuild/
- Qt/
- /webkit/build*/
- /webkit/deps*/

- /buildroot/**/dl/
- /buildroot/**/output*/
- /buildroot/**/ccache/
EOF

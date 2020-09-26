#!/usr/bin/env bash

export GTK_IM_MODULE=xim
export LAPTOP_SCREEN=eDP-1
export DELL_1=DP-1-3
export DELL_2=DP-1-2

xsetroot -solid black

# I do this in /etc/X11 now with XkbOptions rather than like this
#setxkbmap -model pc105 -layout gb -option ctrl:swapcaps -option terminate:ctrl_alt_bksp -option compose:ralt

xrandr --output $LAPTOP_SCREEN --auto \
       --output $DELL_1 --primary --auto --right-of $LAPTOP_SCREEN \
       --output $DELL_2 --auto --right-of $DELL_1 

xrdb -merge ~/.Xresources

GPG_TTY=$(tty)
export GPG_TTY

eval $(ssh-agent -s)

# Seem necessary to avoid a massive hang on GNOME-apps. Not that I use them, I
# try not to ...
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY

exec i3 --shmlog-size=26214400

export GTK_IM_MODULE=xim
export LAPTOP_SCREEN=eDP-1
export DESK_SCREEN_RIGHT=DP-1-2
export DESK_SCREEN_LEFT=DP-1-3

xsetroot -solid gray

setxkbmap -model pc105 -layout gb -option ctrl:swapcaps -option terminate:ctrl_alt_bksp -option compose:ralt

xrandr --output $LAPTOP_SCREEN --primary --auto --below $DESK_SCREEN_LEFT \
       --output $DESK_SCREEN_LEFT --auto --above $LAPTOP_SCREEN --left-of $DESK_SCREEN_RIGHT \
       --output $DESK_SCREEN_RIGHT --auto --above $LAPTOP_SCREEN --right-of $DESK_SCREEN_LEFT

xrdb -merge ~/.Xresources

# https://stackoverflow.com/a/38980986
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

exec i3 --shmlog-size=26214400

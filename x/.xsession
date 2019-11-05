setxkbmap -layout gb -option ctrl:nocaps
sh $HOME/.screenlayout/arandr-config.sh
xrdb -merge ~/.Xresources
exec i3

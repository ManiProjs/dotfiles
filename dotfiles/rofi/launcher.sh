#!/usr/bin/env bash

choice=$(printf "Apps\nCommands\nServices" | rofi -dmenu -p "" -theme launcher.rasi)

case "$choice" in
"Apps")
  rofi -show drun -show-icons -display-drun "" -theme ~/.config/rofi/base.rasi
  ;;

"Commands")
  rofi -show run -display-run "" -theme ~/.config/rofi/base.rasi
  ;;

"Services")
  systemctl list-units --type=service --state=running |
    awk '{print $1}' |
    rofi -dmenu -p "" -theme ~/.config/rofi/base.rasi
  ;;
esac

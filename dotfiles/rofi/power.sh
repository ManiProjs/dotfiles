#!/usr/bin/env bash

choice=$(printf "Lock\nLogout\nReboot\nShutdown" | rofi -dmenu -p "Power" -theme base.rasi)

case "$choice" in
    "Lock") hyprlock ;;
    "Logout") hyprctl dispatch exit ;;
    "Reboot") systemctl reboot ;;
    "Shutdown") systemctl poweroff ;;
esac

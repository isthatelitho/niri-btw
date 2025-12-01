#!/bin/bash
if [ -z $(pidof waybar) ]; then
  waybar -c /home/eli/.config/waybar/config -s /home/eli/.config/waybar/style.css &
else
  pkill waybar
fi

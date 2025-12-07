#!/bin/bash

wallpaper=$(find /home/eli/Pictures/walls/ -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n1)

if [ -z "$wallpaper" ]; then
    echo "No wallpapers found in /home/eli/Pictures/walls/"
    exit 1
fi

# Check if swww daemon is running, start if not
if ! pgrep -x swww-daemon > /dev/null; then
    swww init &
    sleep 1
fi

# Set wallpaper with fade transition
swww img "$wallpaper" --transition-type random --transition-duration 2 --transition-fps 60

wal -i "$wallpaper"

ln -sf "$wallpaper" ~/.cache/wal/current_wallpaper.png

cat ~/.cache/wal/colors-cava > ~/.config/cava/config

mkdir -p ~/.config/btop/themes
cat ~/.cache/wal/colors-btop.theme > ~/.config/btop/themes/pywal.theme

mkdir -p ~/.config/nvim/colors
cat ~/.cache/wal/colors.vim > ~/.config/nvim/colors/pywal.vim

pkill -SIGUSR2 waybar

pkill -USR2 cava

echo "Wallpaper set to: $wallpaper"

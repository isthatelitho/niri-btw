#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="$HOME/Pictures/walls"
CACHE_DIR="$HOME/.cache/rofi-wallpaper"
THUMB_DIR="$CACHE_DIR/thumbs"
SYMLINK="$CACHE_DIR/current_wallpaper"
THUMBNAIL_SIZE="400x900"

ROFI_THEME="$HOME/.config/rofi/wallpaper.rasi"

mkdir -p "$THUMB_DIR"

thumb_name() {
    local img="$1"
    local hash
    hash=$(printf "%s" "$img" | md5sum | cut -d' ' -f1)
    echo "$THUMB_DIR/${hash}.png"
}

make_thumb() {
    local img="$1"
    local thumb="$2"
    local base=$(basename "$img")
    local name="${base%.*}"

    if file --mime-type -b "$img" | grep -q '^video/'; then
        tmp="/tmp/${name}.png"
        ffmpeg -y -i "$img" -frames:v 1 -q:v 2 "$tmp" &>/dev/null
        magick "$tmp" -strip -resize "$THUMBNAIL_SIZE^" -gravity center -extent "$THUMBNAIL_SIZE" "$thumb"
        rm -f "$tmp"
    else
        # Regular image (jpg, png, webp)
        magick "$img"[0] -strip -resize "$THUMBNAIL_SIZE^" -gravity center -extent "$THUMBNAIL_SIZE" "$thumb"
    fi
}

mapfile -t WALLPAPERS < <(
    find "$WALLPAPER_DIR" \
        -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" -o -iname "*.webm" \) \
        | sort
)

if [[ ${#WALLPAPERS[@]} -eq 0 ]]; then
    notify-send "Wallpaper Selector" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

ENTRIES=""

for img in "${WALLPAPERS[@]}"; do
    base=$(basename "$img")
    thumb=$(thumb_name "$img")

    [[ ! -f "$thumb" ]] && make_thumb "$img" "$thumb"

    ENTRIES+="${base}\x00icon\x1f${thumb}\n"
done

if [[ -f "$ROFI_THEME" ]]; then
    SELECTED_NAME=$(printf "%b" "$ENTRIES" | rofi -dmenu -show-icons -i -p "Select Wallpaper" -theme "$ROFI_THEME") || exit 0
else
    SELECTED_NAME=$(printf "%b" "$ENTRIES" | rofi -dmenu -show-icons -i -p "Select Wallpaper" \
        -theme-str 'window {width: 60%; height: 70%;}' \
        -theme-str 'listview {columns: 3; lines: 4;}' \
        -theme-str 'element {padding: 5px; orientation: vertical;}' \
        -theme-str 'element-icon {size: 10em;}') || exit 0
fi

SELECTED=$(printf "%s\n" "${WALLPAPERS[@]}" | grep -F "/$SELECTED_NAME" | head -n 1)

if [[ -z "$SELECTED" ]]; then
    echo "Error: Could not find selected wallpaper"
    exit 1
fi

if ! pgrep -x swww-daemon > /dev/null; then
    swww-daemon --fork 2>/dev/null || swww init &
    sleep 1
fi

swww img "$SELECTED" --transition-type any --transition-duration 2 --transition-fps 60

wal -i "$SELECTED"

ln -sf "$SELECTED" "$SYMLINK"
ln -sf "$SELECTED" ~/.cache/wal/current_wallpaper.png

cat ~/.cache/wal/colors-cava > ~/.config/cava/config

mkdir -p ~/.config/btop/themes
cat ~/.cache/wal/colors-btop.theme > ~/.config/btop/themes/pywal.theme

mkdir -p ~/.config/nvim/colors
cat ~/.cache/wal/colors.vim > ~/.config/nvim/colors/pywal.vim

pkill -SIGUSR2 waybar 2>/dev/null || true
pkill -USR2 cava 2>/dev/null || true


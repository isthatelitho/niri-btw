#!/usr/bin/env bash
set -euo pipefail

# Configuration
WALLPAPER_DIR="$HOME/Pictures/walls"
CACHE_DIR="$HOME/.cache/rofi-wallpaper"
THUMB_DIR="$CACHE_DIR/thumbs"
SYMLINK="$CACHE_DIR/current_wallpaper"
THUMBNAIL_SIZE="400x900"
ROFI_THEME="$HOME/.config/rofi/wallpaper.rasi"

# Performance settings
MAX_PARALLEL_JOBS=4

# SWWW transition settings
TRANSITION_TYPE="any"  # Options: simple, fade, wipe, grow, outer, wave, center, any, random
TRANSITION_DURATION=2
TRANSITION_FPS=60
TRANSITION_ANGLE=45
TRANSITION_POS="center"

mkdir -p "$THUMB_DIR"

# Generate hash-based thumbnail name
thumb_name() {
    local img="$1"
    local hash=$(printf "%s" "$img" | md5sum | cut -d' ' -f1)
    echo "$THUMB_DIR/${hash}.png"
}

# Create thumbnail with video support
make_thumb() {
    local img="$1"
    local thumb="$2"
    local base=$(basename "$img")
    local name="${base%.*}"

    if file --mime-type -b "$img" | grep -q '^video/'; then
        local tmp="/tmp/${name}.png"
        ffmpeg -y -i "$img" -frames:v 1 -q:v 2 "$tmp" &>/dev/null
        magick "$tmp" -strip -resize "$THUMBNAIL_SIZE^" -gravity center -extent "$THUMBNAIL_SIZE" "$thumb"
        rm -f "$tmp"
    else
        magick "$img"[0] -strip -resize "$THUMBNAIL_SIZE^" -gravity center -extent "$THUMBNAIL_SIZE" "$thumb"
    fi
}

# Clean up orphaned thumbnails
cleanup_orphaned_thumbnails() {
    local -A valid_thumbnails
    
    # Build map of valid thumbnail hashes
    while IFS= read -r -d '' image; do
        local thumb_hash=$(printf "%s" "$image" | md5sum | cut -d' ' -f1)
        valid_thumbnails["${thumb_hash}.png"]=1
    done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" -o -iname "*.webm" \) -print0)
    
    # Remove orphaned thumbnails
    while IFS= read -r -d '' thumbnail; do
        local thumb_name=$(basename "$thumbnail")
        [[ -z "${valid_thumbnails[$thumb_name]}" ]] && rm -f "$thumbnail"
    done < <(find "$THUMB_DIR" -type f -name "*.png" -print0)
}

# Set wallpaper with transitions and theme updates
set_wallpaper() {
    local wallpaper="$1"
    
    # Start swww-daemon if not running
    if ! pgrep -x swww-daemon >/dev/null; then
        swww-daemon --fork 2>/dev/null || swww init &
        sleep 1
    fi

    # Choose random transition if set to "any" or "random"
    local transition_type="$TRANSITION_TYPE"
    if [[ "$TRANSITION_TYPE" == "any" || "$TRANSITION_TYPE" == "random" ]]; then
        local choices=("wipe" "center" "fade" "grow")
        transition_type="${choices[$((RANDOM % ${#choices[@]}))]}"
    fi

    # Apply wallpaper with transition
    swww img "$wallpaper" \
        --transition-type "$transition_type" \
        --transition-duration "$TRANSITION_DURATION" \
        --transition-fps "$TRANSITION_FPS" \
        --transition-angle "$TRANSITION_ANGLE" \
        --transition-pos "$TRANSITION_POS"
    
    sleep 0.5  # Wait for transition to start
    
    # Update color scheme with pywal
    wal -n -i "$wallpaper"
    
    # Update symlinks
    ln -sf "$wallpaper" "$SYMLINK"
    ln -sf "$wallpaper" ~/.cache/wal/current_wallpaper.png
    
    # Update app configs
    cat ~/.cache/wal/colors-cava > ~/.config/cava/config 2>/dev/null || true
    pkill -USR2 cava 2>/dev/null || true
    
    mkdir -p ~/.config/btop/themes
    cat ~/.cache/wal/colors-btop.theme > ~/.config/btop/themes/pywal.theme 2>/dev/null || true
    
    mkdir -p ~/.config/nvim/colors
    cat ~/.cache/wal/colors.vim > ~/.config/nvim/colors/pywal.vim 2>/dev/null || true
    
    # Reload Neovim instances with new colorscheme
    for server in $(nvim --serverlist 2>/dev/null); do
        nvim --server "$server" --remote-send '<Esc>:colorscheme pywal<CR>' 2>/dev/null &
    done
    
    # Reload waybar
    pkill -SIGUSR2 waybar 2>/dev/null || true
    
    # Close rofi instances
    pkill rofi 2>/dev/null || true
}

# Main execution
main() {
    # Check dependencies
    for cmd in magick rofi swww wal; do
        command -v "$cmd" &>/dev/null || { 
            notify-send "Wallpaper Selector" "Error: $cmd not found"
            exit 1
        }
    done
    
    # Cleanup orphaned thumbnails in background
    cleanup_orphaned_thumbnails &
    
    # Find all wallpapers
    mapfile -t WALLPAPERS < <(
        find "$WALLPAPER_DIR" \
            -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" -o -iname "*.webm" \) \
            | sort
    )
    
    if [[ ${#WALLPAPERS[@]} -eq 0 ]]; then
        notify-send "Wallpaper Selector" "No wallpapers found in $WALLPAPER_DIR"
        exit 1
    fi
    
    # Get current wallpaper for marking
    local current_wallpaper=""
    [[ -L "$SYMLINK" ]] && current_wallpaper=$(readlink -f "$SYMLINK")
    
    # Generate thumbnails in parallel
    local job_count=0
    for img in "${WALLPAPERS[@]}"; do
        local thumb=$(thumb_name "$img")
        if [[ ! -f "$thumb" ]]; then
            make_thumb "$img" "$thumb" &
            ((job_count++))
            if ((job_count >= MAX_PARALLEL_JOBS)); then
                wait -n
                ((job_count--))
            fi
        fi
    done
    wait
    
    # Build rofi entries with current wallpaper marker
    local entries=""
    for img in "${WALLPAPERS[@]}"; do
        local base=$(basename "$img")
        local thumb=$(thumb_name "$img")
        
        if [[ "$img" == "$current_wallpaper" ]]; then
            entries+="● ${base}\x00icon\x1f${thumb}\n"
        else
            entries+="${base}\x00icon\x1f${thumb}\n"
        fi
    done
    
    # Show rofi selector
    if [[ -f "$ROFI_THEME" ]]; then
        SELECTED_NAME=$(printf "%b" "$entries" | rofi -dmenu -show-icons -i -p "Select Wallpaper" -theme "$ROFI_THEME") || exit 0
    else
        SELECTED_NAME=$(printf "%b" "$entries" | rofi -dmenu -show-icons -i -p "Select Wallpaper" \
            -theme-str 'window {width: 60%; height: 70%;}' \
            -theme-str 'listview {columns: 3; lines: 4;}' \
            -theme-str 'element {padding: 5px; orientation: vertical;}' \
            -theme-str 'element-icon {size: 10em;}') || exit 0
    fi
    
    # Remove marker if present
    SELECTED_NAME="${SELECTED_NAME#● }"
    
    # Find selected wallpaper
    SELECTED=$(printf "%s\n" "${WALLPAPERS[@]}" | grep -F "/$SELECTED_NAME" | head -n 1)
    
    if [[ -z "$SELECTED" ]]; then
        notify-send "Wallpaper Selector" "Error: Could not find selected wallpaper"
        exit 1
    fi
    
    # Apply wallpaper
    set_wallpaper "$SELECTED"
}

main "$@"

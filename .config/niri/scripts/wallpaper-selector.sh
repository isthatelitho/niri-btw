#!/usr/bin/env bash
set -euo pipefail

# configuration
WALLPAPER_DIR="$HOME/Pictures/walls"
CACHE_DIR="$HOME/.cache/rofi-wallpaper"
THUMB_DIR="$CACHE_DIR/thumbs"
BLUR_DIR="$CACHE_DIR/blurred"
SYMLINK="$CACHE_DIR/current_wallpaper"
THUMBNAIL_SIZE="400x900"
ROFI_THEME="$HOME/.config/rofi/wallpaper.rasi"

# jobs BRO JOBS
MAX_PARALLEL_JOBS=4
THUMB_QUALITY=85  # JPEG quality for thumbnails

# cause im lazy
TRANSITION_TYPE="any"
TRANSITION_DURATION=2
TRANSITION_FPS=60
TRANSITION_ANGLE=45
TRANSITION_POS="center"

# i love blur
BLUR_RADIUS="0x10"

mkdir -p "$THUMB_DIR" "$BLUR_DIR"

# dunno whaat this do
thumb_name() {
    printf "%s" "$1" | md5sum | awk '{print "'$THUMB_DIR'/"$1".jpg"}'
}

# or this
blur_name() {
    printf "%s" "$1" | md5sum | awk '{print "'$BLUR_DIR'/"$1".jpg"}'
}

# video? why even
make_thumb() {
    local img="$1" thumb="$2"
    
    if file -b --mime-type "$img" | grep -q '^video/'; then
        ffmpeg -loglevel error -i "$img" -vframes 1 -vf "scale=${THUMBNAIL_SIZE}:force_original_aspect_ratio=increase,crop=${THUMBNAIL_SIZE}" -q:v 2 "$thumb" 2>/dev/null
    else
        magick "$img"[0] -strip -quality "$THUMB_QUALITY" -resize "$THUMBNAIL_SIZE^" -gravity center -extent "$THUMBNAIL_SIZE" "$thumb" 2>/dev/null
    fi
}

# yeah whatever
make_blurred() {
    local img="$1" blurred="$2"
    
    if file -b --mime-type "$img" | grep -q '^video/'; then
        ffmpeg -loglevel error -i "$img" -vframes 1 -vf "scale=1920:-1,boxblur=10:2" -q:v 3 "$blurred" 2>/dev/null
    else
        magick "$img"[0] -scale 25% -blur "$BLUR_RADIUS" -resize 1920x1080\! -quality 80 "$blurred" 2>/dev/null
    fi
}

# blur blur this
cleanup_orphaned_thumbnails() {
    local tmp_valid="/tmp/valid_hashes_$$.txt"
    
    # hash abash bash bash bash b
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" -o -iname "*.webm" \) -print0 | \
        xargs -0 -I {} sh -c 'printf "%s" "{}" | md5sum' | awk '{print $1".jpg"}' > "$tmp_valid"
    
    # remove the garbage
    comm -23 <(ls -1 "$THUMB_DIR" | sort) <(sort "$tmp_valid") | xargs -I {} rm -f "$THUMB_DIR/{}" 2>/dev/null
    comm -23 <(ls -1 "$BLUR_DIR" | sort) <(sort "$tmp_valid") | xargs -I {} rm -f "$BLUR_DIR/{}" 2>/dev/null
    
    rm -f "$tmp_valid"
}

# biggest thing 
set_wallpaper() {
    local wallpaper="$1"
    
    # incase i forg
    pgrep -x swww-daemon >/dev/null || { swww-daemon --fork 2>/dev/null || swww init & sleep 0.5; }
    
    # yeah true
    pgrep -f "swww-daemon.*--namespace overview" >/dev/null || { swww-daemon --namespace overview & sleep 0.5; }

    # cause i cant decide (fade sucks)
    local transition_type="$TRANSITION_TYPE"
    if [[ "$TRANSITION_TYPE" =~ ^(any|random)$ ]]; then
        local choices=(wipe center grow outer)
        transition_type="${choices[$((RANDOM % 4))]}"
    fi

    # Apply 
    swww img "$wallpaper" \
        --transition-type "$transition_type" \
        --transition-duration "$TRANSITION_DURATION" \
        --transition-fps "$TRANSITION_FPS" \
        --transition-angle "$TRANSITION_ANGLE" \
        --transition-pos "$TRANSITION_POS" &
    
    # Generate and apply blurred version
    local blurred=$(blur_name "$wallpaper")
    (
        [[ ! -f "$blurred" ]] && make_blurred "$wallpaper" "$blurred"
        swww img -n overview "$blurred" \
            --transition-type "$transition_type" \
            --transition-duration "$TRANSITION_DURATION" \
            --transition-fps "$TRANSITION_FPS" 2>/dev/null 
    ) &
    
    # paypal
    (
        wal -n -q -i "$wallpaper"
        
        # Update symlinks
        ln -sf "$wallpaper" "$SYMLINK"
        ln -sf "$wallpaper" ~/.cache/wal/current_wallpaper.png
        
        # Update app configs nvim doesnt work iirc
        {
            [[ -f ~/.cache/wal/colors-cava ]] && cat ~/.cache/wal/colors-cava > ~/.config/cava/config
            mkdir -p ~/.config/btop/themes
            [[ -f ~/.cache/wal/colors-btop.theme ]] && cat ~/.cache/wal/colors-btop.theme > ~/.config/btop/themes/pywal.theme
            mkdir -p ~/.config/nvim/colors
            [[ -f ~/.cache/wal/colors.vim ]] && cat ~/.cache/wal/colors.vim > ~/.config/nvim/colors/pywal.vim
        } 2>/dev/null

[[ -f ~/.cache/wal/zathurarc ]] && cat ~/.cache/wal/zathurarc > ~/.config/zathura/zathurarc

        # Reload apps
        pkill -USR2 cava 2>/dev/null || true
        pkill -SIGUSR2 waybar 2>/dev/null || true
        pkill rofi 2>/dev/null || true
        
        # prob doesnt work
        for server in $(nvim --serverlist 2>/dev/null); do
            nvim --server "$server" --remote-send '<Esc>:colorscheme pywal<CR>' 2>/dev/null &
        done

	pgrep -x qutebrowser >/dev/null && qutebrowser --target auto ":config-source" 2>/dev/null &
    ) &
}

# execution
main() {
    # whatever
    for cmd in magick rofi swww wal; do
        command -v "$cmd" >/dev/null || { 
            notify-send "Wallpaper Selector" "Error: $cmd not found"
            exit 1
        }
    done
    
    # clen
    nice -n 19 bash -c "$(declare -f cleanup_orphaned_thumbnails); cleanup_orphaned_thumbnails" &
    
    # Find all wallpapers 
    mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" -o -iname "*.webm" \) | sort)
    
    [[ ${#WALLPAPERS[@]} -eq 0 ]] && { notify-send "Wallpaper Selector" "No wallpapers found in $WALLPAPER_DIR"; exit 1; }
    
    # Get current wallpaper
    local current_wallpaper=""
    [[ -L "$SYMLINK" ]] && current_wallpaper=$(readlink -f "$SYMLINK")
    
    # Generate thumbnails 
    local pids=()
    for img in "${WALLPAPERS[@]}"; do
        local thumb=$(thumb_name "$img")
        if [[ ! -f "$thumb" ]]; then
            make_thumb "$img" "$thumb" &
            pids+=($!)
            
            # Wait when max jobs reached
            if ((${#pids[@]} >= MAX_PARALLEL_JOBS)); then
                wait "${pids[0]}" 2>/dev/null
                pids=("${pids[@]:1}")
            fi
        fi
    done
    wait
    
    # Build rofi entries
    local entries=()
    for img in "${WALLPAPERS[@]}"; do
        local base=$(basename "$img")
        local thumb=$(thumb_name "$img")
        
        if [[ "$img" == "$current_wallpaper" ]]; then
            entries+=("● ${base}\x00icon\x1f${thumb}")
        else
            entries+=("${base}\x00icon\x1f${thumb}")
        fi
    done
    
    # Show rofi selector
    if [[ -f "$ROFI_THEME" ]]; then
        SELECTED_NAME=$(printf "%b\n" "${entries[@]}" | rofi -dmenu -show-icons -i -p "Select Wallpaper" -theme "$ROFI_THEME") || exit 0
    else
        SELECTED_NAME=$(printf "%b\n" "${entries[@]}" | rofi -dmenu -show-icons -i -p "Select Wallpaper" \
            -theme-str 'window {width: 60%; height: 70%;}' \
            -theme-str 'listview {columns: 3; lines: 4;}' \
            -theme-str 'element {padding: 5px; orientation: vertical;}' \
            -theme-str 'element-icon {size: 10em;}') || exit 0
    fi
    
    # Remove marker and find selected wallpaper
    SELECTED_NAME="${SELECTED_NAME#● }"
    SELECTED=$(printf "%s\n" "${WALLPAPERS[@]}" | grep -F "/$SELECTED_NAME" | head -n1)
    
    [[ -z "$SELECTED" ]] && { notify-send "Wallpaper Selector" "Error: Could not find selected wallpaper"; exit 1; }
    
    # Apply wallpaper
    set_wallpaper "$SELECTED"
}

main "$@"

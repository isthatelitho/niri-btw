source /usr/share/cachyos-fish-config/cachyos-config.fish

#  overwrite greeting
# potentially disabling fastfetch
function fish_greeting
#    # smth smth
end

alias ffa='anifetch Downloads/nisioisin-anime.mp4 -ff -r 10 -W 40 -H 20 -c "--symbols wide --fg-only"; printf '\033c'; stty sane'
alias ytp='pipe-viewer'
alias ytaudio='yt-dlp --js-runtimes deno:/home/eli/.deno/bin/deno --remote-components ejs:github --format "bestaudio" --extract-audio --audio-format "mp3" --audio-quality "0"'
alias ls='exa --icons'
alias icat="kitty +kitten icat --scale-up"
alias rm="rm -i"
alias up="cd .." 
alias osu-import='~/.config/niri/scripts/osu-organize.sh'
alias gpush='git push origin main'
alias ff='clear && fastfetch'

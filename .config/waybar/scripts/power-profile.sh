#!/bin/bash

current=$(powerprofilesctl get 2>/dev/null || echo "balanced")

if [[ "$1" == "cycle" ]]; then
    case "$current" in
        balanced) powerprofilesctl set performance 2>/dev/null; current="performance" ;;
        performance) powerprofilesctl set power-saver 2>/dev/null; current="power-saver" ;;
        power-saver) powerprofilesctl set balanced 2>/dev/null; current="balanced" ;;
    esac
fi

case "$current" in
    balanced)
        echo '{"text":"<u>BAL</u> PER BTR","tooltip":"Current: balanced\nClick to cycle","class":"balanced"}'
        ;;
    performance)
        echo '{"text":"BAL <u>PER</u> BTR","tooltip":"Current: performance\nClick to cycle","class":"performance"}'
        ;;
    power-saver)
        echo '{"text":"BAL PER <u>BTR</u>","tooltip":"Current: power-saver\nClick to cycle","class":"power-saver"}'
        ;;
esac

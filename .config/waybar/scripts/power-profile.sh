#!/bin/bash

if [ "$1" == "cycle" ]; then
    current=$(powerprofilesctl get 2>/dev/null || echo "balanced")
    case "$current" in
        balanced)
            powerprofilesctl set performance 2>/dev/null
            ;;
        performance)
            powerprofilesctl set power-saver 2>/dev/null
            ;;
        power-saver)
            powerprofilesctl set balanced 2>/dev/null
            ;;
    esac
fi

current=$(powerprofilesctl get 2>/dev/null || echo "balanced")

bal="BAL"
per="PER"
btr="BTR"

case "$current" in
    balanced)
        bal="<u>BAL</u>"
        ;;
    performance)
        per="<u>PER</u>"
        ;;
    power-saver)
        btr="<u>BTR</u>"
        ;;
esac

echo "{\"text\":\"[$bal $per $btr]\",\"tooltip\":\"Current: $current\\nClick to cycle\",\"class\":\"$current\"}"

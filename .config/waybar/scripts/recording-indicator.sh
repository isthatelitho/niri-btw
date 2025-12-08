#!/bin/bash

STATE_FILE="/tmp/recording_state"

if [ -f "$STATE_FILE" ]; then
    echo '{"text": " 󰑊 ", "class": "recording", "tooltip": "Recording in progress!"}'
else
    echo '{"text": "", "class": "not-recording"}'
fi

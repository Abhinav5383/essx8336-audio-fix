#!/usr/bin/env bash

CARD_INFO=$(pactl list cards | awk '
/^Card #/ { if (++c > 1) exit }
{ print }
')

CARD_INDEX="$(printf '%s\n' "$CARD_INFO" \
    | awk -F'"' '/api\.alsa\.card =/ { print $2 }')"

amixer -c "$CARD_INDEX" sset 'Internal Mic' cap unmute 1>/dev/null

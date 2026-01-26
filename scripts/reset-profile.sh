#!/usr/bin/env bash

# check if pactl and amixer are available
if ! command -v pactl >/dev/null 2>&1; then
    echo "pactl command not found. Please install libpulse." >&2
    exit 1
elif ! command -v amixer >/dev/null 2>&1; then
    echo "amixer command not found. Please install alsa-utils." >&2
    exit 1
fi

CARD_INFO=$(pactl list cards | awk '
/^Card #/ { if (++c > 1) exit }
{ print }
')

CARD_NAME="$(printf '%s\n' "$CARD_INFO" | awk -F': ' '/^\s*Name:/ { print $2 }')"

CARD_INDEX="$(printf '%s\n' "$CARD_INFO" \
    | awk -F'"' '/api\.alsa\.card =/ { print $2 }')"

ACTIVE_PROFILE="$(printf '%s\n' "$CARD_INFO" \
    | awk -F': ' '/^\s*Active Profile:/ { print $2 }')"


if [[ "$ACTIVE_PROFILE" == "off" ]]; then
    echo "Warning: The current active profile is set to 'off'."
    echo "Please select a valid profile through 'pavucontrol > Configuration' before running this script."
    exit 1
fi

# unmute the internal mic
amixer -c "$CARD_INDEX" sset 'Internal Mic' cap unmute 1>/dev/null

# need to toggle card-profile once to reset the audio stack properly
pactl set-card-profile "$CARD_NAME" off
pactl set-card-profile "$CARD_NAME" "$ACTIVE_PROFILE"

echo "Successfully reset the audio profile for card '$CARD_NAME'."
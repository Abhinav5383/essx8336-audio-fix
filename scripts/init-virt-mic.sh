#!/usr/bin/env bash

REAL_MIC_SOURCE=$(pactl list sources short | awk '$2 ~ /^alsa_input\./ { print $2 }')
VIRT_SINK="virt_mic_sink"
VIRT_MIC="virtual_mic"

if pactl list sources short | awk '{print $2}' | grep -qx "$VIRT_MIC"; then
    echo "Warning: '$VIRT_MIC' already exists. Exiting." >&2
    exit 0
fi

pactl load-module module-null-sink \
    sink_name="$VIRT_SINK" \
    sink_properties="device.description=$VIRT_SINK"

pactl load-module module-loopback \
    source="$REAL_MIC_SOURCE" \
    sink="$VIRT_SINK"

pactl load-module module-remap-source \
    master="${VIRT_SINK}.monitor" \
    source_name="$VIRT_MIC" \
    source_properties="device.description=Virtual Mic"

pactl set-default-source $VIRT_MIC

echo
echo "Created virtual capture device: $VIRT_MIC"
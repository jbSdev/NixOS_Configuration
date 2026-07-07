#!/usr/bin/env bash
set -euo pipefail

ASSETS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mode="${1:?usage: day-night-switch.sh <day|night|auto>}"

if [[ "$mode" == "auto" ]]; then
    # String comparison on zero-padded HH:MM is safe and correct for this;
    # numeric comparison (e.g. `[ "$h" -ge 0730 ]`) is NOT safe here because
    # bash treats leading-zero numbers as octal in arithmetic contexts.
    now=$(date +%H:%M)
    if [[ "$now" > "07:29" && "$now" < "20:00" ]]; then
        mode=day
    else
        mode=night
    fi
fi

cp "$ASSETS_DIR/waybar-$mode.css" "$ASSETS_DIR/waybar-active.css"

wallpaper="$ASSETS_DIR/wallpaper_$mode.jpg"
hyprctl hyprpaper wallpaper "eDP-1,$wallpaper"
hyprctl hyprpaper wallpaper "HDMI-1,$wallpaper"

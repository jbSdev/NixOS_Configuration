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

# reload_on_style_change's inotify watch doesn't reliably fire through the
# mkOutOfStoreSymlink -> nix-store-symlink -> live-file chain; force it.
pkill -SIGUSR2 waybar || true

wallpaper="$ASSETS_DIR/wallpaper_$mode.jpg"

# hyprpaper's IPC can still be starting up when this runs from exec-once at
# login, racing the call below; poll until it responds before setting.
for _ in $(seq 1 20); do
    hyprctl hyprpaper listactive &>/dev/null && break
    sleep 0.5
done

for monitor in $(hyprctl monitors -j | jq -r '.[].name'); do
    hyprctl hyprpaper wallpaper "$monitor,$wallpaper" || true
done

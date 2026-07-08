#!/usr/bin/env bash
set -euo pipefail

declare -A prev_names
first_run=1

while true; do
    declare -A curr_names

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        mac="${line#Device }"
        mac="${mac%% *}"
        name="${line#Device "$mac" }"
        curr_names["$mac"]="$name"
    done < <(bluetoothctl devices Connected)

    if [[ "$first_run" -eq 0 ]]; then
        for mac in "${!curr_names[@]}"; do
            if [[ -z "${prev_names[$mac]+set}" ]]; then
                notify-send "Bluetooth" "${curr_names[$mac]} connected"
            fi
        done

        for mac in "${!prev_names[@]}"; do
            if [[ -z "${curr_names[$mac]+set}" ]]; then
                notify-send "Bluetooth" "${prev_names[$mac]} disconnected"
            fi
        done
    fi

    prev_names=()
    for mac in "${!curr_names[@]}"; do
        prev_names["$mac"]="${curr_names[$mac]}"
    done

    first_run=0
    sleep 1
done

#!/usr/bin/env bash

# Get position and length from playerctl
read -r position length < <(playerctl metadata --format '{{position}} {{mpris:length}}' 2>/dev/null)

# Width of the progress bar in characters
WIDTH=100

if [[ -z "$position" || -z "$length" || "$length" -eq 0 ]]; then
    exit 1
fi

# Convert microseconds to seconds
pos_sec=$(( position / 1000000 ))
len_sec=$(( length / 1000000 ))

# Calculate filled characters
filled=$(( pos_sec * WIDTH / len_sec ))
[[ $filled -gt $WIDTH ]] && filled=$WIDTH

empty=$(( WIDTH - filled ))

# Build bar
bar=""
for (( i=0; i<filled; i++ )); do
    bar="${bar}▬"
done
for (( i=0; i<empty; i++ )); do
    bar="${bar}_"
done

echo "$bar"

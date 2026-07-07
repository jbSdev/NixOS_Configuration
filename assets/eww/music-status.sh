#!/usr/bin/env bash
#
# Emits one JSON line per second describing the currently active MPRIS
# player (via playerctld). Consumed by eww's `music` deflisten variable.

CACHE_DIR="$HOME/.cache/eww-music"
ASSETS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
YOUTUBE_ICON="$ASSETS_DIR/youtube.svg"
NOTE_ICON="$ASSETS_DIR/music-note.svg"

mkdir -p "$CACHE_DIR"

json_escape() {
    local s=$1
    s=${s//\\/\\\\}
    s=${s//\"/\\\"}
    printf '%s' "$s"
}

while true; do
    status=$(playerctl status 2>/dev/null)

    if [[ -z "$status" ]]; then
        printf '{"status":"Stopped","title":"","artist":"","art":"%s","progress":0}\n' "$NOTE_ICON"
        sleep 1
        continue
    fi

    title=$(playerctl metadata xesam:title 2>/dev/null)
    artist=$(playerctl metadata xesam:artist 2>/dev/null)
    art_url=$(playerctl metadata mpris:artUrl 2>/dev/null)
    track_url=$(playerctl metadata xesam:url 2>/dev/null)
    player=$(playerctl metadata --format '{{playerName}}' 2>/dev/null)

    read -r position length < <(playerctl metadata --format '{{position}} {{mpris:length}}' 2>/dev/null)

    progress=0
    if [[ -n "$position" && -n "$length" && "$length" -gt 0 ]]; then
        progress=$(( position * 100 / length ))
        (( progress > 100 )) && progress=100
    fi

    art="$NOTE_ICON"
    if [[ "$track_url" == *youtube.com* || "$track_url" == *youtu.be* || "$player" == *firefox* || "$player" == *chrom* ]]; then
        # Browser playback of a YouTube URL — show a generic video icon instead of art
        art="$YOUTUBE_ICON"
    elif [[ "$art_url" == file://* ]]; then
        art="${art_url#file://}"
    elif [[ "$art_url" == http://* || "$art_url" == https://* ]]; then
        hash=$(printf '%s' "$art_url" | md5sum | cut -d' ' -f1)
        cached="$CACHE_DIR/$hash.jpg"
        if [[ ! -s "$cached" ]]; then
            curl -sL "$art_url" -o "$cached" 2>/dev/null || rm -f "$cached"
        fi
        [[ -s "$cached" ]] && art="$cached" || art="$NOTE_ICON"
    fi

    printf '{"status":"%s","title":"%s","artist":"%s","art":"%s","progress":%s}\n' \
        "$(json_escape "$status")" "$(json_escape "$title")" "$(json_escape "$artist")" "$(json_escape "$art")" "$progress"

    sleep 1
done

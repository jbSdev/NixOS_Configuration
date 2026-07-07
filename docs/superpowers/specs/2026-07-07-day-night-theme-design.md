# Day/Night Wallpaper & Waybar Theme — Design

## Goal

Automatically switch two things on the same schedule already used by `hyprsunset` (day starts 07:30, night starts 20:00):

1. **Wallpaper** — `wallpaper_day.jpg` during the day, `wallpaper_night.jpg` at night.
2. **Waybar colors** — black text/icons during the day (against the light wallpaper), white at night (current look), with the bar itself staying fully transparent as it is today.

Explicitly out of scope: kitty/terminal colors, mako notification styling, the eww music popup — none of these change.

## Components

### 1. Wallpaper files — out-of-store paths

`home/jb/hyprland.nix` currently loads the wallpaper as a Nix-store path:

```nix
let wallpaper = ../../assets/wallpaper.jpg; in
...
services.hyprpaper.settings.preload = [ "${wallpaper}" ];
```

This changes to the same out-of-store convention already used for `waybar.css` and `mpris-progress.sh` — absolute paths into the live repo checkout, not Nix store copies:

```nix
let
  wallpaperDay   = "${config.home.homeDirectory}/nixConfig/assets/wallpaper_day.jpg";
  wallpaperNight = "${config.home.homeDirectory}/nixConfig/assets/wallpaper_night.jpg";
in
services.hyprpaper.settings = {
  preload = [ wallpaperDay wallpaperNight ];
  wallpaper = [
    { fit_mode = "fill"; monitor = "eDP-1";  path = wallpaperNight; }
    { fit_mode = "fill"; monitor = "HDMI-1"; path = wallpaperNight; }
  ];
};
```

Both images are preloaded at hyprpaper startup so the switch script can flip between them instantly via `hyprctl hyprpaper wallpaper` without restarting the hyprpaper daemon. Initial `wallpaper` block defaults to night; the login-time seed step (Component 4) corrects this immediately if it's actually daytime.

### 2. Waybar stylesheets — day/night/active split

- `assets/waybar-night.css` — the current `assets/waybar.css`, renamed. No content changes.
- `assets/waybar-day.css` — new file, same rules with colors inverted per the mapping below.
- `assets/waybar-active.css` — new, generated, **not** hand-edited and **gitignored**. This is what `~/.config/waybar/style.css` symlinks to (via the existing `mkOutOfStoreSymlink` pattern in `hyprland.nix`). The switch script overwrites this file's *contents* (via `cp`, not by changing the symlink) with whichever variant is currently active.

Waybar already has `reload_on_style_change = true` on both bars, so modifying `waybar-active.css` triggers an automatic hot-reload — no waybar restart needed.

Color mapping (day theme is the mechanical inversion of night; the bar background is already fully transparent on both, so only foreground/overlay colors change):

| Element | Night (current) | Day |
|---|---|---|
| Text/icons (`* { color }`) | `#ffffff` | `#000000` |
| Workspace hover background | `rgba(255,255,255,0.1)` | `rgba(0,0,0,0.1)` |
| Active workspace underline | `#222436` | unchanged — distinct accent color, legible on both backdrops |
| Muted pulseaudio icon | `gray` | unchanged — neutral on both |
| `#custom-progress` text | `#ffffff` @ 0.6 opacity | `#000000` @ 0.6 opacity |

### 3. Switch script

`assets/day-night-switch.sh <day|night>`:

```bash
#!/usr/bin/env bash
set -euo pipefail

ASSETS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mode="$1"  # "day" or "night"

cp "$ASSETS_DIR/waybar-$mode.css" "$ASSETS_DIR/waybar-active.css"

wallpaper="$ASSETS_DIR/wallpaper_$mode.jpg"
hyprctl hyprpaper wallpaper "eDP-1,$wallpaper"
hyprctl hyprpaper wallpaper "HDMI-1,$wallpaper"
```

Follows this repo's existing convention for live asset scripts (plain bash, no Nix interpolation, executable bit set directly on the file — same as `mpris-progress.sh` and `music-status.sh`).

### 4. Trigger wiring

New home-manager module `home/jb/day-night-theme.nix`:

```nix
{ config, ... }:
let
  switchScript = "${config.home.homeDirectory}/nixConfig/assets/day-night-switch.sh";
in
{
  systemd.user.services = {
    theme-day = {
      Unit.Description = "Switch wallpaper/waybar theme (day)";
      Service = { Type = "oneshot"; ExecStart = "${switchScript} day"; };
    };
    theme-night = {
      Unit.Description = "Switch wallpaper/waybar theme (night)";
      Service = { Type = "oneshot"; ExecStart = "${switchScript} night"; };
    };
  };

  systemd.user.timers = {
    theme-day = {
      Unit.Description = "Timer for day theme switch";
      Timer = { OnCalendar = "*-*-* 07:30:00"; Persistent = true; };
      Install.WantedBy = [ config.wayland.systemd.target ];
    };
    theme-night = {
      Unit.Description = "Timer for night theme switch";
      Timer = { OnCalendar = "*-*-* 20:00:00"; Persistent = true; };
      Install.WantedBy = [ config.wayland.systemd.target ];
    };
  };
}
```

`Persistent = true` means a transition missed during suspend fires on the next wake, mirroring the pattern already present in `hyprsunset.nix`.

`home/jb/hyprland.nix`'s `exec-once` gains one more entry — an inline shell snippet that compares the current time against `07:30`/`20:00` and calls `day-night-switch.sh` with the correct argument immediately at login, so the state is correct right away rather than waiting for the next timer to fire.

## Out of scope

- kitty/terminal color scheme (explicitly unchanged).
- mako notification styling (unchanged).
- eww music popup styling (unchanged).
- Solar-based (lat/long) scheduling — fixed clock times only, matching the already-approved `hyprsunset` schedule.

## Testing

- After rebuild, confirm `~/.config/waybar/style.css` resolves to `assets/waybar-active.css` and its content matches the theme appropriate for the current time.
- Manually run `assets/day-night-switch.sh day` and `... night`, confirm waybar text color flips without a waybar restart, and confirm the wallpaper on both monitors changes.
- Confirm `systemctl --user list-timers` shows `theme-day.timer` and `theme-night.timer` scheduled for 07:30/20:00.
- Log out/in (or restart Hyprland) at a few different times of day and confirm the login-time seed step picks the correct theme immediately.

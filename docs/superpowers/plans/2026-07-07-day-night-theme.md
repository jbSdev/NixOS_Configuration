# Day/Night Wallpaper & Waybar Theme Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Automatically switch the desktop wallpaper and waybar's text color between day/night variants at 07:30/20:00, the same schedule already used by `hyprsunset`.

**Architecture:** A single bash script (`assets/day-night-switch.sh`) does the actual switching — overwriting a generated waybar stylesheet (which waybar hot-reloads via its existing `reload_on_style_change`) and calling `hyprctl hyprpaper wallpaper` to swap the preloaded wallpaper. Two `systemd.user` timers (mirroring the pattern already used internally by `hyprsunset`) fire the script at the two boundary times; Hyprland's `exec-once` calls it once more in `auto` mode at login so the correct state applies immediately rather than waiting for the next timer.

**Tech Stack:** Nix (home-manager `systemd.user.services`/`timers`, `services.hyprpaper`, `programs.waybar`), bash, Hyprland/`hyprctl`, GTK CSS.

## Global Constraints

- Only wallpaper and waybar colors change; kitty/terminal, mako, and the eww music popup are explicitly unchanged (per spec's "Out of scope").
- Day/night boundary times are `07:30` (day starts) and `20:00` (night starts) — must match `home/jb/hyprsunset.nix`'s existing schedule exactly.
- New scripts follow this repo's existing convention for live-editable assets: plain bash, no Nix string interpolation, referenced via `${config.home.homeDirectory}/nixConfig/assets/...` out-of-store paths (same pattern as `mpris-progress.sh` and `assets/eww/music-status.sh`), not copied into the Nix store.
- Every Nix change must be validated with `nix flake check` before committing. Because flakes only evaluate git-tracked files, validate using a throwaway git copy so real repo state (including anything not yet staged) isn't disturbed:
  ```bash
  SCRATCH=/home/jb/.claude/jobs/dd2544f4/tmp/nixConfig-check
  rm -rf "$SCRATCH"
  mkdir -p "$SCRATCH"
  cp -a /home/jb/nixConfig/. "$SCRATCH/"
  rm -rf "$SCRATCH/.git" "$SCRATCH/.claude"
  cd "$SCRATCH"
  git init -q && git add -A && git commit -q -m "check" --author="tmp <tmp@tmp>"
  nix flake check --no-build
  cd /home/jb/nixConfig
  rm -rf "$SCRATCH"
  ```
  Expected final output line: `all checks passed!`

---

### Task 1: Waybar day/night stylesheets

**Files:**
- Modify (rename): `assets/waybar.css` → `assets/waybar-night.css`
- Create: `assets/waybar-day.css`

**Interfaces:**
- Produces: `assets/waybar-night.css` and `assets/waybar-day.css`, two complete GTK CSS files with identical structure differing only in color values. Consumed by Task 2 (bootstrap + switch script copies one of these into `waybar-active.css`).

- [ ] **Step 1: Rename the current stylesheet to `waybar-night.css`**

```bash
cd /home/jb/nixConfig
git mv assets/waybar.css assets/waybar-night.css
```

- [ ] **Step 2: Verify the rename preserved content exactly**

Run: `git diff --cached --stat`
Expected: `assets/waybar.css => assets/waybar-night.css | 0` (zero content changes, pure rename)

- [ ] **Step 3: Create `assets/waybar-day.css`**

This is `waybar-night.css` with every `#ffffff` foreground color inverted to `#000000`, and hover overlays inverted from white-on-dark to black-on-light. All background-transparency, the `#222436` accent underline, and the `gray` muted-icon color are unchanged (see spec's color mapping table — they're accents/neutrals, not text/bg pairs).

```css
* {
    color: #000000;
    font-size: 12px;
    font-family: "Terminus (TTF)";
    min-height: 0;;
}

window#waybar {
    /* border: 1px yellow solid; */
}

window#waybar , window#waybar * {
    background-color: rgba(0, 0, 0, 0);
    /* min-height: 0; */
}

/*
 * .modules-left   > widget > *,
 * .modules-center > widget > *,
 * .modules-right  > widget > * {
 *     padding: 0 12px;
 *     #<{(| border: 1px red solid; |)}>#
 * }
 */

.modules-left > widget > * {
    padding-left: 12px;
}

.modules-right > widget > * {
    padding-right: 12px;
}

#workspaces {
    padding: 2px 10px;
    /* border: 1px green solid; */
}

#workspaces button {
    border-radius: 0px;
    padding: 0 4px;
    /* border: 1px red solid; */
}

button:hover {
    background: transparent;
    box-shadow: none;;
}

#workspaces button:hover {
    background-color: rgba(0, 0, 0, 0.1);
    background-image: none;
    box-shadow: none;
    border: none;
    padding: 0 4px;
    margin: 0;
    transition: background-color 0.3s;
}

#workspaces button.active {
    box-shadow: inset 0 -2px #222436;
}

#workspaces button.active:hover {
    background-color: rgba(0, 0, 0, 0.1);
    box-shadow: inset 0 -2px #222436;
}

.modules-center > widget > #player {
    margin-top: 4px;
}

#mpris {
    padding: 0;
    min-height: 17px;
    padding: 0;
    margin: 0;
    font-size: 12px;
    /* border: 1px pink solid; */
}

#pulseaudio.muted {
    color: gray;
}

#custom-progress {
    font-size: 6px;
    margin-top: -1px;
    letter-spacing: -1px;
    color: #000000;
    opacity: 0.6;
    /* border: 1px green solid; */
}
```

- [ ] **Step 4: Verify the two files differ only in the expected color values**

Run: `diff /home/jb/nixConfig/assets/waybar-night.css /home/jb/nixConfig/assets/waybar-day.css`
Expected output (exactly 3 changed lines — the `*` color, and the two hover backgrounds, plus `#custom-progress` color; 4 diff hunks total):
```
2c2
<     color: #ffffff;
---
>     color: #000000;
51c51
<     background-color: rgba(255, 255, 255, 0.1);
---
>     background-color: rgba(0, 0, 0, 0.1);
65c65
<     background-color: rgba(255, 255, 255, 0.1);
---
>     background-color: rgba(0, 0, 0, 0.1);
90c90
<     color: #ffffff;
---
>     color: #000000;
```

- [ ] **Step 5: Stage and commit**

```bash
cd /home/jb/nixConfig
git add assets/waybar-night.css assets/waybar-day.css
git commit -m "Split waybar stylesheet into day/night variants"
```

---

### Task 2: Switch script and generated active stylesheet

**Files:**
- Create: `assets/day-night-switch.sh`
- Create: `assets/waybar-active.css` (bootstrap default; gitignored, not committed)
- Modify: `.gitignore`

**Interfaces:**
- Consumes: `assets/waybar-day.css`, `assets/waybar-night.css` (Task 1).
- Produces: `assets/day-night-switch.sh <day|night|auto>` — an executable script. Consumed by Task 3 (`ExecStart`) and Task 4 (`exec-once` entry). Also produces `assets/waybar-active.css`, the file `home/jb/hyprland.nix`'s `xdg.configFile."waybar/style.css"` symlink will target (Task 4).

- [ ] **Step 1: Write `assets/day-night-switch.sh`**

```bash
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
```

Note: this folds the spec's separately-described "exec-once inline shell snippet" for computing day-vs-night into the script itself as a third `auto` mode, rather than embedding time-comparison logic as an inline string inside `hyprland.nix`. Same behavior, but keeps the logic in one shellcheck-able, testable file instead of splitting it across a Nix string and a script.

- [ ] **Step 2: Make it executable**

```bash
chmod +x /home/jb/nixConfig/assets/day-night-switch.sh
```

- [ ] **Step 3: Lint with shellcheck**

Run: `nix run nixpkgs#shellcheck -- /home/jb/nixConfig/assets/day-night-switch.sh`
Expected: no output, exit code 0.

- [ ] **Step 4: Verify script behavior with a stubbed `hyprctl`**

`hyprctl` only works inside a live Hyprland session, so stub it to confirm the script's own logic (mode resolution, file copy, argument construction) is correct in isolation:

```bash
TMP=/home/jb/.claude/jobs/dd2544f4/tmp/switch-verify
rm -rf "$TMP"
mkdir -p "$TMP/bin"
cat > "$TMP/bin/hyprctl" <<'EOF'
#!/usr/bin/env bash
echo "hyprctl-called: $*" >> "$HYPRCTL_LOG"
EOF
chmod +x "$TMP/bin/hyprctl"

cd /home/jb/nixConfig/assets
HYPRCTL_LOG="$TMP/log"

echo "--- night ---"
rm -f "$HYPRCTL_LOG"; PATH="$TMP/bin:$PATH" ./day-night-switch.sh night
diff waybar-active.css waybar-night.css && echo "waybar-active.css matches night (OK)"
cat "$HYPRCTL_LOG"

echo "--- day ---"
rm -f "$HYPRCTL_LOG"; PATH="$TMP/bin:$PATH" ./day-night-switch.sh day
diff waybar-active.css waybar-day.css && echo "waybar-active.css matches day (OK)"
cat "$HYPRCTL_LOG"

rm -rf "$TMP"
```

Expected output:
```
--- night ---
waybar-active.css matches night (OK)
hyprctl-called: hyprpaper wallpaper eDP-1,/home/jb/nixConfig/assets/wallpaper_night.jpg
hyprctl-called: hyprpaper wallpaper HDMI-1,/home/jb/nixConfig/assets/wallpaper_night.jpg
--- day ---
waybar-active.css matches day (OK)
hyprctl-called: hyprpaper wallpaper eDP-1,/home/jb/nixConfig/assets/wallpaper_day.jpg
hyprctl-called: hyprpaper wallpaper HDMI-1,/home/jb/nixConfig/assets/wallpaper_day.jpg
```
(Leaves `assets/waybar-active.css` present on disk containing the day variant — that becomes the bootstrap default in Step 5.)

- [ ] **Step 5: Add `.gitignore` entry**

`assets/waybar-active.css` is generated at runtime and must never be hand-edited or committed — add it alongside the existing entries:

```bash
cd /home/jb/nixConfig
printf '%s\n' "assets/waybar-active.css" >> .gitignore
cat .gitignore
```

Expected: `.gitignore` now contains `.claude`, `CLAUDE.md`, and `assets/waybar-active.css`.

- [ ] **Step 6: Confirm `waybar-active.css` exists on disk but is untracked**

The Step 4 run already left a real `waybar-active.css` on disk (bootstrap default) — this matters so the symlink Task 4 creates has something to point at immediately, without waiting for the first timer/login run.

Run: `git status --short assets/`
Expected: `waybar-active.css` does NOT appear (ignored), while `waybar-day.css`/`waybar-night.css` show as already committed (no output) and `day-night-switch.sh` shows as untracked (`??`).

- [ ] **Step 7: Stage and commit**

```bash
cd /home/jb/nixConfig
git add assets/day-night-switch.sh .gitignore
git commit -m "Add day/night switch script for wallpaper and waybar theme"
```

---

### Task 3: systemd timers module

**Files:**
- Create: `home/jb/day-night-theme.nix`
- Modify: `home/jb/default.nix:4-6`

**Interfaces:**
- Consumes: `assets/day-night-switch.sh` (Task 2), `config.wayland.systemd.target` (existing home-manager Wayland-session integration, same option `home/jb/hyprsunset.nix` already relies on).
- Produces: `systemd.user.services.theme-day`/`theme-night` and `systemd.user.timers.theme-day`/`theme-night`, active once this module is imported.

- [ ] **Step 1: Write `home/jb/day-night-theme.nix`**

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

- [ ] **Step 2: Wire the module into `home/jb/default.nix`**

Current `home/jb/default.nix:4-6`:
```nix
	imports = [ ./hyprland.nix ./binds.nix ./gaming.nix ./music.nix ./neovim.nix
		./git.nix ./pass.nix ./sops.nix ./firefox.nix ./kitty.nix ./eww.nix ./hyprsunset.nix
	];
```

Change to:
```nix
	imports = [ ./hyprland.nix ./binds.nix ./gaming.nix ./music.nix ./neovim.nix
		./git.nix ./pass.nix ./sops.nix ./firefox.nix ./kitty.nix ./eww.nix ./hyprsunset.nix
		./day-night-theme.nix
	];
```

- [ ] **Step 3: Validate with a throwaway flake check**

Run the validation snippet from Global Constraints (staging both new/changed files first, since flakes only see git-tracked content):
```bash
cd /home/jb/nixConfig
git add home/jb/day-night-theme.nix home/jb/default.nix
```
then run the `SCRATCH=...` block from Global Constraints.
Expected final line: `all checks passed!`

- [ ] **Step 4: Commit**

```bash
cd /home/jb/nixConfig
git commit -m "Add systemd timers for day/night theme switch"
```

---

### Task 4: Wire wallpaper and waybar symlink into hyprland.nix

**Files:**
- Modify: `home/jb/hyprland.nix:1-6` (let bindings)
- Modify: `home/jb/hyprland.nix:33-38` (exec-once)
- Modify: `home/jb/hyprland.nix:149-152` (waybar style.css symlink)
- Modify: `home/jb/hyprland.nix:184-202` (hyprpaper settings)

**Interfaces:**
- Consumes: `assets/day-night-switch.sh` (Task 2), `assets/waybar-active.css` (Task 2), `assets/wallpaper_day.jpg`/`wallpaper_night.jpg` (already present on disk).
- Produces: the fully wired runtime behavior — nothing downstream depends on this file further within this plan; Task 5 validates the whole thing end to end.

- [ ] **Step 1: Replace the wallpaper let-binding**

Current (`home/jb/hyprland.nix:1-6`):
```nix
{ pkgs, config, ... }:
let
    wallpaper = ../../assets/wallpaper.jpg;
    # waybarcss = ../../assets/waybar.css;
    barHeight = 30;
in
```

Change to:
```nix
{ pkgs, config, ... }:
let
    wallpaperDay   = "${config.home.homeDirectory}/nixConfig/assets/wallpaper_day.jpg";
    wallpaperNight = "${config.home.homeDirectory}/nixConfig/assets/wallpaper_night.jpg";
    barHeight = 30;
in
```

(Drops the stale `# waybarcss` comment along the way — it referred to a nix-store path pattern that's no longer used for waybar styling either, per the existing out-of-store symlink already below it.)

- [ ] **Step 2: Add the login-time auto-seed to `exec-once`**

Current (`home/jb/hyprland.nix:33-38`):
```nix
			exec-once = [
				"waybar"
				"hyprpaper"
				"mako"
				"eww daemon"
			];
```

Change to:
```nix
			exec-once = [
				"waybar"
				"hyprpaper"
				"mako"
				"eww daemon"
				"${config.home.homeDirectory}/nixConfig/assets/day-night-switch.sh auto"
			];
```

Ordered last so `hyprpaper` (required for the `hyprctl hyprpaper wallpaper` calls to succeed) is already running by the time this fires.

- [ ] **Step 3: Point the waybar style symlink at the generated active stylesheet**

Current (`home/jb/hyprland.nix:149-152`):
```nix
    xdg.configFile."waybar/style.css" = {
        source = config.lib.file.mkOutOfStoreSymlink
            "${config.home.homeDirectory}/nixConfig/assets/waybar.css";
    };
```

Change to:
```nix
    xdg.configFile."waybar/style.css" = {
        source = config.lib.file.mkOutOfStoreSymlink
            "${config.home.homeDirectory}/nixConfig/assets/waybar-active.css";
    };
```

- [ ] **Step 4: Preload and reference both wallpapers in hyprpaper**

Current (`home/jb/hyprland.nix:184-202`):
```nix
	services.hyprpaper = {
        enable = true;
        settings = {
            splash    = false;
            preload   = [ "${wallpaper}" ];
            wallpaper = [
                {
                    fit_mode = "fill";
                    monitor  = "eDP-1";
                    path = "${wallpaper}";
                }
                {
                    fit_mode = "fill";
                    monitor = "HDMI-1";
                    path = "${wallpaper}";
                }
            ];
        };
    };
```

Change to:
```nix
	services.hyprpaper = {
        enable = true;
        settings = {
            splash    = false;
            preload   = [ wallpaperDay wallpaperNight ];
            wallpaper = [
                {
                    fit_mode = "fill";
                    monitor  = "eDP-1";
                    path = wallpaperNight;
                }
                {
                    fit_mode = "fill";
                    monitor = "HDMI-1";
                    path = wallpaperNight;
                }
            ];
        };
    };
```

Both images are preloaded so `day-night-switch.sh`'s `hyprctl hyprpaper wallpaper` calls can swap between them without restarting hyprpaper. The static `wallpaper` block defaults to night; the `exec-once` auto-seed from Step 2 corrects this immediately at login if it's actually daytime.

- [ ] **Step 5: Validate with a throwaway flake check**

```bash
cd /home/jb/nixConfig
git add home/jb/hyprland.nix
```
then run the `SCRATCH=...` block from Global Constraints.
Expected final line: `all checks passed!`

- [ ] **Step 6: Commit**

```bash
cd /home/jb/nixConfig
git commit -m "Switch wallpaper and waybar style to day/night-aware paths"
```

---

### Task 5: Full validation and manual verification checklist

**Files:** none (validation only)

**Interfaces:**
- Consumes: everything from Tasks 1-4.
- Produces: confidence the whole feature evaluates correctly; hands off a manual checklist for post-rebuild confirmation (this sandbox has no live Hyprland/systemd-user session to exercise runtime behavior directly).

- [ ] **Step 1: Run a full flake check on the real repo state**

```bash
cd /home/jb/nixConfig
git status --short
```
Expected: working tree clean (everything from Tasks 1-4 committed).

Then run the `SCRATCH=...` validation block from Global Constraints one more time against the now-fully-committed repo.
Expected final line: `all checks passed!`

- [ ] **Step 2: Confirm the script and generated files are in the expected end state**

```bash
ls -la /home/jb/nixConfig/assets/ | grep -E "waybar-(day|night|active)\.css|day-night-switch\.sh|wallpaper_(day|night)\.jpg"
readlink -f /home/jb/nixConfig/assets/waybar-active.css 2>/dev/null || echo "waybar-active.css is a plain file (expected, not a symlink)"
```
Expected: all five files present, `day-night-switch.sh` executable (`-rwxr-xr-x`).

- [ ] **Step 3: Hand off the post-rebuild manual checklist**

These require an actual rebuild + live Hyprland/systemd-user session, which isn't available in this environment — to be run by the user after `rebuild`:

- [ ] `systemctl --user list-timers | grep theme-` shows `theme-day.timer` and `theme-night.timer` scheduled for 07:30/20:00.
- [ ] `readlink ~/.config/waybar/style.css` resolves to `~/nixConfig/assets/waybar-active.css`.
- [ ] Manually run `~/nixConfig/assets/day-night-switch.sh day`, confirm waybar text turns black without a waybar restart, and both monitors' wallpapers switch to `wallpaper_day.jpg`.
- [ ] Manually run `~/nixConfig/assets/day-night-switch.sh night`, confirm the reverse.
- [ ] Log out and back in (or `hyprctl reload` a fresh session) at a time known to be within one theme or the other, and confirm the correct theme applies immediately without waiting for a timer.

## Spec Coverage Check

- Wallpaper out-of-store paths, both preloaded → Task 4, Steps 1 & 4.
- Waybar day/night/active stylesheet split + color mapping → Task 1, Task 2.
- Switch script → Task 2.
- systemd timers + `Persistent = true` → Task 3.
- `exec-once` login-time seed → Task 4, Step 2 (implemented as `day-night-switch.sh auto`, per the noted deviation in Task 2 Step 1).
- Out-of-scope items (kitty, mako, eww) → untouched by every task above; no task modifies `kitty.nix`, `hyprland.nix`'s `services.mako` block, or `assets/eww/*`.

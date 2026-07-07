# Desktop Notifications — Design

## Goal

Get Hyprland desktop popup notifications working for two sources:

1. **Steam** — friend messages, download-complete.
2. **Claude Code** — when a session finishes responding (`Stop`) or is blocked waiting on input/permission (`Notification`).

Discord is explicitly out of scope (not installed yet).

## Components

### 1. Notification daemon — mako

Added via home-manager's `services.mako` module in `home/jb/hyprland.nix`, next to the existing Hyprland/waybar/hyprpaper config.

- Registers a D-Bus service file (`dbus.packages`), so mako is D-Bus-activated on first notification — no `exec-once` entry needed.
- Styled to match the existing waybar aesthetic (`assets/waybar.css`): dark, semi-transparent background, white text, thin border, top-right anchor, short default timeout (~5s).

```nix
services.mako = {
  enable = true;
  settings = {
    anchor = "top-right";
    background-color = "#000000cc";
    text-color = "#ffffff";
    border-color = "#222436";
    border-size = 1;
    border-radius = 8;
    default-timeout = 5000;
    font = "Terminus (TTF) 11";
    width = 320;
    height = 100;
    margin = 10;
    padding = 10;
  };
};
```

Exact values may be tuned once seen on screen.

### 2. Steam

No nix changes. Steam is already installed (`home/jb/gaming.nix`, `modules/system/gaming.nix`). Its "notify me about friend messages / downloads" setting lives in Steam's own runtime config and is not nix-managed. Once mako is running, enabling that toggle in **Steam → Settings → Notifications** is sufficient — Steam's native Linux notifications go through the standard `org.freedesktop.Notifications` D-Bus interface that mako implements.

This is called out as a one-time manual step post-rebuild, not part of the nix config.

### 3. Claude Code hooks

Added to the **global** `~/.claude/settings.json` (applies to all projects on this machine, not just this repo) under a `hooks` key:

- `Notification` event → fires when Claude Code is blocked waiting for a permission decision or other input.
- `Stop` event → fires when Claude Code finishes responding.

Each hook runs a `notify-send` command. The hook receives JSON on stdin (including `cwd`); `jq` extracts the working directory's basename to identify which project/session the notification is about, e.g.:

- Title: `Claude Code — nixConfig`
- Body: `Waiting for input` (Notification) or `Task finished` (Stop)

Example hook command:

```bash
jq -r '.cwd' | xargs basename | xargs -I{} notify-send "Claude Code — {}" "Waiting for input"
```

(Exact quoting/escaping to be finalized during implementation.)

**New packages** needed in `home/jb/default.nix`:
- `libnotify` — provides the `notify-send` CLI used by the hooks.
- `jq` — used by the hook commands to parse stdin JSON.

## Out of scope

- Discord notifications (not installed).
- Steam's in-app notification toggle (manual, not nix-managed).
- Notification history/do-not-disturb UI (would require swaync instead of mako — not requested).

## Testing

- `notify-send "test" "hello"` after rebuild should produce a mako popup styled per above.
- Manually trigger a Claude Code permission prompt and confirm a popup appears.
- Manually let a Claude Code turn finish and confirm a popup appears.
- Enable Steam notification settings and trigger a friend message or finish a download to confirm a popup appears.

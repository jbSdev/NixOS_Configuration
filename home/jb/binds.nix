{ lib, ... }:
let
    # Lua config helpers: each entry renders as hl.bind(keys, dispatcher[, opts]).
    # `keys` and `dispatcher` are raw Lua expressions.
    lua = lib.generators.mkLuaInline;
    str = lib.generators.toLua { };
    bind' = keys: dispatcher: opts: { _args = [ (lua keys) (lua dispatcher) ] ++ lib.optional (opts != null) opts; };
    bind  = keys: dispatcher: bind' (str keys) dispatcher null;
    exec  = cmd: "hl.dsp.exec_cmd(${str cmd})";

    # Screenshot target, expanded by the shell at run time
    shotFile = "~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png";

    directions = { left = "left"; right = "right"; up = "up"; down = "down"; h = "left"; l = "right"; k = "up"; j = "down"; };
in
{
    wayland.windowManager.hyprland = {
        settings.bind = [
            (bind "SUPER + SHIFT + R" (exec "hyprctl reload"))
            (bind "SUPER + Return"    "hl.dsp.exec_cmd(terminal)")
            (bind "SUPER + SHIFT + Q" "hl.dsp.window.close()")
            (bind "SUPER + Escape"    ''function() hl.dispatch(hl.dsp.dpms({ action = "off" })); hl.dispatch(hl.dsp.dpms({ action = "on" })) end'')
            (bind "SUPER + D"         (exec "rofi -show drun"))
            (bind "SUPER + SHIFT + X" (exec "loginctl lock-session"))   # via hypridle, so immurok can unlock
        ]
        # SUPER + [0-9] -> workspace 1-10, SUPER + SHIFT + [0-9] -> move window there
        ++ lib.concatMap (i: let key = toString (lib.mod i 10); ws = toString i; in [
            (bind "SUPER + ${key}"         "hl.dsp.focus({ workspace = ${ws} })")
            (bind "SUPER + SHIFT + ${key}" "hl.dsp.window.move({ workspace = ${ws} })")
        ]) (lib.range 1 10)
        # Arrows and hjkl: focus / move window
        ++ lib.concatLists (lib.mapAttrsToList (key: dir: [
            (bind "SUPER + ${key}"         ''hl.dsp.focus({ direction = "${dir}" })'')
            (bind "SUPER + SHIFT + ${key}" ''hl.dsp.window.move({ direction = "${dir}" })'')
        ]) directions)
        ++ [
            (bind "SUPER + F" "hl.dsp.window.fullscreen()")
            (bind "SUPER + V" ''hl.dsp.window.float({ action = "toggle" })'')
            (bind "SUPER + R" ''hl.dsp.submap("resize")'')

            # Brightness
            (bind "XF86MonBrightnessUp"   (exec "brightnessctl set 5%+"))
            (bind "XF86MonBrightnessDown" (exec "brightnessctl set 5%-"))
            # Audio
            (bind "XF86AudioRaiseVolume"  (exec "pactl set-sink-volume @DEFAULT_SINK@ +5%"))
            (bind "XF86AudioLowerVolume"  (exec "pactl set-sink-volume @DEFAULT_SINK@ -5%"))
            (bind "XF86AudioMute"         (exec "pactl set-sink-mute   @DEFAULT_SINK@ toggle"))

            # Media playback
            (bind "XF86AudioPlay" (exec "playerctl play-pause"))
            (bind "XF86AudioNext" (exec "playerctl next"))
            (bind "XF86AudioPrev" (exec "playerctl previous"))

            # PrintScreen

                # Full screen -> save to ~/Pictures/Screenshots
            (bind' ''mod .. " + PRINT"'' (exec "grim ${shotFile}") null)
                # Select region -> save to ~/Pictures/Screenshots
            (bind' ''mod .. " + SHIFT + S"'' (exec "grim -g \"$(slurp)\" ${shotFile}") null)
                # Full screen -> clipboard
            (bind "PRINT" (exec "grim - | wl-copy"))
                # Select region -> clipboard
            (bind' ''mod .. " + CTRL + S"'' (exec "grim -g \"$(slurp)\" - | wl-copy") null)

            # Move / resize floating window on SUPER + l-click / r-click
            (bind' (str "SUPER + mouse:272") "hl.dsp.window.drag()"   { mouse = true; })
            (bind' (str "SUPER + mouse:273") "hl.dsp.window.resize()" { mouse = true; })
        ];
        submaps = {
            resize.settings.bind = [
                (bind' (str "right") "hl.dsp.window.resize({ x = 20, y = 0, relative = true })"  { repeating = true; })
                (bind' (str "left")  "hl.dsp.window.resize({ x = -20, y = 0, relative = true })" { repeating = true; })
                (bind' (str "up")    "hl.dsp.window.resize({ x = 0, y = -20, relative = true })" { repeating = true; })
                (bind' (str "down")  "hl.dsp.window.resize({ x = 0, y = 20, relative = true })"  { repeating = true; })
                (bind  "escape" ''hl.dsp.submap("reset")'')
            ];
        };
    };

    programs.spotify-player.keymaps = [
        {
            command = "Mute";
            key_sequence = "m";
        }
        {
            command = "None";
            key_sequence = "q";
        }
    ];
}

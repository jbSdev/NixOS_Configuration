{ inputs, ... }:
{
    wayland.windowManager.hyprland = {
        settings.bind = [
            "SUPER SHIFT, R, exec, hyprctl reload"
            "SUPER, Return, exec, $terminal"
            "SUPER SHIFT, Q, killactive"
            "SUPER, Escape, exec, hyprctl dispath dpms off && hyprctl dispatch dpms on"
            "SUPER, D, exec, rofi -show drun"

            "SUPER, 1, workspace, 1"
            "SUPER, 2, workspace, 2"
            "SUPER, 3, workspace, 3"
            "SUPER, 4, workspace, 4"
            "SUPER, 5, workspace, 5"
            "SUPER, 6, workspace, 6"
            "SUPER, 7, workspace, 7"
            "SUPER, 8, workspace, 8"
            "SUPER, 9, workspace, 9"
            "SUPER, 0, workspace, 10"

            "SUPER SHIFT, 1, movetoworkspace, 1"
            "SUPER SHIFT, 2, movetoworkspace, 2"
            "SUPER SHIFT, 3, movetoworkspace, 3"
            "SUPER SHIFT, 4, movetoworkspace, 4"
            "SUPER SHIFT, 5, movetoworkspace, 5"
            "SUPER SHIFT, 6, movetoworkspace, 6"
            "SUPER SHIFT, 7, movetoworkspace, 7"
            "SUPER SHIFT, 8, movetoworkspace, 8"
            "SUPER SHIFT, 9, movetoworkspace, 9"
            "SUPER SHIFT, 0, movetoworkspace, 10"

            "SUPER, left,  movefocus, l"
            "SUPER, right, movefocus, r"
            "SUPER, up,    movefocus, u"
            "SUPER, down,  movefocus, d"

            "SUPER, h,     movefocus, l"
            "SUPER, l,     movefocus, r"
            "SUPER, k,     movefocus, u"
            "SUPER, j,     movefocus, d"

            "SUPER, F, fullscreen"
            "SUPER, R, submap, resize"

            # Brightness
            ", XF86MonBrightnessUp,   exec, brightnessctl set 5%+"
            ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
            # Audio
            ", XF86AudioRaiseVolume,  exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
            ", XF86AudioLowerVolume,  exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"
            ", XF86AudioMute,         exec, pactl set-sink-mute   @DEFAULT_SINK@ toggle"

        ];
        submaps = {
            resize.settings.bind = [
                ", right,  resizeactive,  20 0"
                ", left,   resizeactive, -20 0"
                ", up,     resizeactive,  0 -20"
                ", down,   resizeactive,  0  20"
                ", escape, submap,        reset"
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

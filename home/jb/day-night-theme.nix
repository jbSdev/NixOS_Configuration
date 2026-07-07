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

{ config, ... }:
let
  notifyScript = "${config.home.homeDirectory}/nixConfig/assets/bluetooth-notify.sh";
in
{

    systemd.user.services.bluetooth-notify = {
        Unit.Description = "Notify on Bluetooth device connect/disconnect";
        Service = { Type = "simple"; ExecStart = notifyScript; Restart = "on-failure"; };
        Install.WantedBy = [ config.wayland.systemd.target ];
    };

}

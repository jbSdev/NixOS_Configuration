{ inputs, pkgs, ... }:
let
    wallpaper = ../../assets/wallpaper.jpg;
in
{

	wayland.windowManager.hyprland = {
		enable = true;
		xwayland.enable = true;
		configType = "hyprlang";

		settings = {
			monitor = [ ",preferred,auto,1" ];

			env = [
				"LIBVA_DRIVER_TYPE,nvidia"
				"XDG_SESSION_TYPE,wayland"
				"GBM_BACKEND,nvidia-drm"
				"__GLX_VENDOR_LIBRARY_NAME,nvidia"
				"WLR_NO_HARDWARE_CURSORS,1"

                # Cursor
                "HYPRCURSOR_THEME,rose-pine-hyprcursor"
                "HYPRCURSOR_SIZE,24"
			];

			"$terminal" = "kitty";
			"$menu" = "rofi -show drun";
			"$mod" = "SUPER";

			exec-once = [
				"waybar"
				"hyprpaper"
			];

			input = {
				kb_layout = "us";
				follow_mouse = 1;
				touchpad.natural_scroll = true;
			};

			general = {
				gaps_in = 5;
				gaps_out = 10;
				border_size = 2;
				layout = "dwindle";
			};

			decoration = {
				rounding = 8;
				blur.enabled = true;
			};
		};
	};

	programs.waybar = {
        enable = true;
        settings = {
            topBar = {
                layer = "top";
                position = "top";
                height = 25;
                modules-left = [ "hyprland/workspaces" ];
                modules-center = [ "clock" ];
                modules-right = [ "pulseaudio" "battery" ];

                "hyprland/workspaces" = {
                    disable-scroll = "true";
                    all-outputs = "true";
                };

                "clock" = {
                    format = "{:%H:%M}";
                    tooltip-format = "{:%A, %d %B %Y}";
                };
            };
            botBar = {
                layer = "bottom";
                position = "bottom";
                height = 25;
                modules-left = [ "custom/publicip" ];
                modules-center = [];
                modules-right = [ "hyprland/window" ];

                "network" = {
                    interface = "wlp4s0";
                    format = "{ipaddr}";
                    format-wifi = "{ipaddr} ({signalStrength}%)";
                    format-ethernet = "{ipaddr}";
                    format-disconnected = "DISC";
                    # tooltip-format = "{ifname} via {gwaddr}";
                    # tooltip-format-wifi = "{essid} ({signalStrength}%)";
                    # tooltip-format-ethernet = "{ipaddr}";
                    # tooltip-format-disconnected = "Disconnected";
                    max-length = 50;
                };
                
                "custom/publicip" = {
                    exec = "curl -s ifconfig.me";
                    interval = 60;
                    format = "{}";
                    tooltip-format = "{ifname} @ {ipaddr}";
                };
            };
        };
    };

	programs.rofi.enable = true;
	programs.kitty.enable = true;

	services.hyprpaper = {
        enable = true;
        settings = {
            splash    = false;
            preload   = [ "${wallpaper}" ];
            wallpaper = {
                fit_mode = "fill";
                monitor  = "eDP-1";
                path = "${wallpaper}";
            };
        };
    };
}

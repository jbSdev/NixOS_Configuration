{ pkgs, config, ... }:
let
    wallpaper = ../../assets/wallpaper.jpg;
    # waybarcss = ../../assets/waybar.css;
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
                reload_on_style_change = true;
                modules-left   = [ "hyprland/workspaces" ];
                modules-center = [ "clock" ];
                modules-right  = [ "pulseaudio" "battery" ];

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
                reload_on_style_change = true;
                modules-left   = [ "custom/publicip" ];
                modules-center = [ "mpris" ];
                modules-right  = [ "hyprland/window" ];
                
                "custom/publicip" = {
                    format = "{}";
                    tooltip = false;
                    exec = pkgs.writeShellScript "publicip" ''curl -s ifconfig.me'';
                    interval = 60;
                };

                "hyprland/window" = {
                    format = "{initialTitle}";
                    tooltip = false;
                };

                "mpris" = {
                    format = "{status_icon} {artist} - {title}";
                    # format-paused = "{statusIcon} {artist} - {title}";
                    format-firefox = "{status_icon} {title}";
                    tooltip = false;
                    player-icons = {
                        default = "";
                        mpv = " ";
                    };
                    status-icons = {
                        paused = "";
                        playing = "";
                        stopped = "";
                    };
                    interval = 2;
                };
            };
        };
        # style = builtins.readFile waybarcss;
    };

    xdg.configFile."waybar/style.css" = {
        source = config.lib.file.mkOutOfStoreSymlink
            "${config.home.homeDirectory}/nixConfig/assets/waybar.css";
    };

	programs.rofi.enable = true;

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
}

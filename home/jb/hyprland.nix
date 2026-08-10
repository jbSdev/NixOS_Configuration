{ pkgs, config, ... }:
let
    wallpaperDay   = "${config.home.homeDirectory}/nixConfig/assets/wallpaper_day.jpg";
    wallpaperNight = "${config.home.homeDirectory}/nixConfig/assets/wallpaper_night.jpg";
    barHeight = 30;
in
{

	wayland.windowManager.hyprland = {
		enable = true;
		xwayland.enable = true;
		configType = "hyprlang";

		settings = {
			monitor = [
                "eDP-1, 1920x1080@144, 0x0, 1"
                "DP-1,  1920x1080@120, 1920x-420, 1, transform, 1"
            ];

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
				"mako"
				"eww daemon"
				"${config.home.homeDirectory}/nixConfig/assets/day-night-switch.sh auto"
			];

			input = {
				kb_layout = "us";
				follow_mouse = 1;
				touchpad.natural_scroll = true;
			};

			general = {
				gaps_in = 5;
				gaps_out = "2,10,2,10";
				border_size = 1;
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
                height = barHeight;
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

                "pulseaudio" = {
                    on-click = "eww open --toggle music-popup";
                    tooltip = false;
                };

                # Pin to the laptop battery explicitly; without `bat`, waybar
                # auto-detects and inotify-watches every /sys/class/power_supply/*
                # entry, including the DualSense's Bluetooth battery report. That
                # entry disappears on controller disconnect, and waybar's watch
                # teardown throws an uncaught exception that crashes the whole bar.
                "battery" = {
                    bat = "BAT0";
                };
            };
            botBar = {
                layer = "bottom";
                position = "bottom";
                height = barHeight;
                reload_on_style_change = true;
                modules-left   = [ "custom/customip" ];
                # modules-center = [ "mpris" ];
                modules-center = [ "group/player" ];
                modules-right  = [ "hyprland/window" ];
                
                "custom/customip" = {
                    format = "{}";
                    tooltip = true;
                    return-type = "json";
                    exec = pkgs.writeShellScript "customip" ''
                        public_ip=$(curl -s ifconfig.me)
                        iface=$(${pkgs.iproute2}/bin/ip route get 1.1.1.1 | awk '{for (i=1;i<=NF;i++) if ($i=="dev") print $(i+1); exit}')
                        local_ip=$(${pkgs.iproute2}/bin/ip -4 addr show "$iface" | awk '/inet /{print $2}' | cut -d/ -f1)
                        if [ -d "/sys/class/net/$iface/wireless" ]; then
                            prefix="W"
                        else
                            prefix="E"
                        fi
                        printf '{"text":"%s", "tooltip":"%s:%s"}\n' "$public_ip" "$prefix" "$local_ip"
                    '';
                    interval = 60;
                };

                "hyprland/window" = {
                    format = "{initialTitle}";
                    tooltip = false;
                };

                "mpris" = {
                    format = "{artist} - {title}";
                    format-paused = "{status_icon} {artist} - {title}";
                    format-firefox = "{status_icon} {title}";
                    tooltip = false;
                    status-icons = {
                        paused = "󰏤";
                        playing = "";
                        stopped = "";
                    };
                    interval = 2;
                };

                "custom/progress" = {
                    exec = "${config.home.homeDirectory}/nixConfig/assets/mpris-progress.sh";
                    interval = 1;
                    format = "{}";
                    tooltip = false;
                };

                "group/player" = {
                    orientation = "vertical";
                    modules = [ "mpris" "custom/progress" ];
                };
            };
        };
        # style = builtins.readFile waybarcss;
    };

    xdg.configFile."waybar/style.css" = {
        source = config.lib.file.mkOutOfStoreSymlink
            "${config.home.homeDirectory}/nixConfig/assets/waybar-active.css";
    };

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
            width = 270;
            height = 100;
            margin = "0,10,10";
            padding = 10;

            "urgency=low" = {
                border-color = "#e0af68";
                format = "<b><span foreground=\"#e0af68\">WARNING: %s</span></b>\\n%b";
            };

            "urgency=critical" = {
                border-color = "#f7768e";
                format = "<b><span foreground=\"#f7768e\">ERROR: %s</span></b>\\n%b";
            };
        };
    };

	programs.rofi.enable = true;

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
                {
                    fit_mode = "fill";
                    monitor = "DP-1";
                    path = wallpaperNight;
                }
            ];
        };
    };
}

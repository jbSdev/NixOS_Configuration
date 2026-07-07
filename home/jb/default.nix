{ inputs, pkgs, ... }:
{

	imports = [ ./hyprland.nix ./binds.nix ./gaming.nix ./music.nix ./neovim.nix
		./git.nix ./pass.nix ./sops.nix ./firefox.nix ./kitty.nix ./day-night-theme.nix
	];

	modules.neovim.enable = true;

	home.username = "jb";
	home.homeDirectory = "/home/jb";
	home.stateVersion = "26.05";

	programs.home-manager.enable = true;

	home.packages = with pkgs; [
            kitty
			eza
			bat
			btop
			home-manager
			pulseaudio
			direnv                      # Managing shell environment

			# Hyprland
			wl-clipboard
			grim
			slurp
			inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default

			libreoffice-fresh           # LibreOffice Suite
			winbox4                     # MicroTik Router Setup
			cloudflared                 # Cloudflare Access
			obsidian                    # Obsidian Notes
	];

	services.gpg-agent = {
		enable = true;
		enableSshSupport = true;
		sshKeys = [ "98BAF6BE30F5B285D677851110E4D0E6F1236A87" ];
		pinentry.package = pkgs.pinentry-gtk2;
	};

	programs.ssh = {
		enable = true;
		enableDefaultConfig = false;
		settings = {
			"*" = {
				IdentityAgent = "/run/user/1000/gnupg/S.gpg-agent.ssh";
			};
			"svr.jesien.net" = {
				ProxyCommand  = "/run/current-system/sw/bin/cloudflared access ssh --hostname %h";
			};
			"HS" = {
				HostName = "10.0.10.4";
				User = "jb";
			};
		};
	};

	programs.bluetuith.enable = true;
	programs.imv.enable = true;
	programs.claude-code.enable = true;

}

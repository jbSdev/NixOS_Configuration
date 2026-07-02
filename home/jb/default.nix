{ inputs, pkgs, config, ... }:
{

	imports = [ ./hyprland.nix ./binds.nix ./gaming.nix ./music.nix ./neovim.nix 
		./git.nix ./pass.nix ./sops.nix ./firefox.nix
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

	programs.zsh = {
		enable = true;
		autosuggestion.enable = true; 
		syntaxHighlighting.enable = true;

		shellAliases = {
			ls  = "eza -hl";
			lsa = "eza -ahl";
			cls = "clear";
			rebuild = "sudo nixos-rebuild switch --flake ~/nixConfig/.#victus";
			rebuild-nvim = "cd ~/nixConfig && \
					sudo nix flake lock --update-input nixos-neovim && \
					sudo nixos-rebuild switch --flake ~/nixConfig/#.victus && \
					cd -";
			cat = "bat --paging=never $@";
			mountusb  = "sudo mount /dev/sda1 /run/mount && cd /run/mount";
			umountusb = "cd ~ && sudo umount /dev/sda1";
		};

		initContent = ''
			lsf() { eza -ahl | grep $1}

			zstyle ':omz:plugins:eza' 'dirs-first' yes
			zstyle ':omz:plugins:eza' 'git-status' yes
			zstyle ':omz:plugins:eza' 'header' yes

			# direnv-lsp for flake-nvim work
			eval "$(${pkgs.direnv}/bin/direnv hook zsh)"

			# DEV SHELLS
			dev() {
				case "$1" in
					"cpp11" )
						nix develop ~/nixConfig/.#cpp11
						;;
					"cpp23" )
						nix develop ~/nixConfig/.#cpp23
						;;
					"lua" )
						nix develop ~/nixConfig/.#lua
						;;
					"python" )
						nix develop ~/nixConfig/.#python
						;;
					"rust" )
						nix develop ~/nixConfig/.#rust
						;;
					"go" )
						nix develop ~/nixConfig/.#go
						;;
					"powershell" )
						nix develop ~/nixConfig/.#powershell
						;;
					* )
						echo "No such dev shell! Available:"
						echo " - cpp11"
						echo " - cpp23"
						echo " - lua"
						echo " - python"
						echo " - rust"
						echo " - go"
						echo " - powershell"
						;;
					esac
			}
		'';

		oh-my-zsh = {
			enable = true;
			theme = "awesomepanda";
			plugins = [ "git" "history" "eza" ];
		};

		history.size = 10000;
		setOptions = [
			"HIST_IGNORE_ALL_DUPS"
		];
	};

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

	xdg.configFile."nvim" = {
		source = inputs.nvim-config.outPath;
		recursive = true;
	};

	programs.bluetuith.enable = true;
	programs.imv.enable = true;
	programs.claude-code.enable = true;

}

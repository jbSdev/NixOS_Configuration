{ inputs, pkgs, config, ... }:
{

	imports = [ ./hyprland.nix ./bind.nix ./gaming.nix ./music.nix ];

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
        
        # Hyprland
		wl-clipboard
		grim
		slurp
        inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default

        libreoffice-fresh           # LibreOffice Suite
        winbox4                     # MicroTik Router Setup
	];

	programs.zsh = {
		enable = true;
		autosuggestion.enable = true; 
		syntaxHighlighting.enable = true;

		shellAliases = {
			ls  = "eza -hl";
			lsa = "eza -ahl";
			rebuild = "sudo nixos-rebuild switch --flake ~/nixConfig/.#victus";
			cat = "bat --paging=never $@";
            mountusb  = "sudo mount /dev/sda1 /run/mount && cd /run/mount";
            umountusb = "cd ~ && sudo umount /dev/sda1";
		};

		initContent = ''
			lsf() { eza -ahl | grep $1}
			zstyle ':omz:plugins:eza' 'dirs-first' yes
			zstyle ':omz:plugins:eza' 'git-status' yes
			zstyle ':omz:plugins:eza' 'header' yes

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
					* )
						echo "No such dev shell! Available:"
						echo " - cpp11"
						echo " - cpp23"
						echo " - lua"
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
            "github.com" = {
                User = "git";
                IdentityAgent = "/run/user/1000/gnupg/S.gpg-agent.ssh";
            };
        };
    };

	programs.neovim = {
		enable = true;
		defaultEditor = true;
		viAlias = true;
		vimAlias = true;
	};
	xdg.configFile."nvim" = {
		source = inputs.nvim-config.outPath;
		recursive = true;
	};

	programs.firefox = {
		enable = true;
        profiles.default.extraConfig = builtins.readFile ../../assets/user.js;
	};

    programs.git = {
        enable = true;
        settings = {
            user.name = "jbSdev";
            user.email = "antoni.jesien@gmail.com";
            init.defaultBranch = "main";
            url."git@github.com".insteadOf = "https://github.com";
            core.sshCommand = "ssh";
        };
    };

    programs.bluetuith.enable = true;
    
}

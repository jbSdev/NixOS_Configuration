{ pkgs, ... }:
{

    programs.kitty = {
        enable = true;
        font = {
            name = "Terminus (TTF)";
            size = 12;
        };
    };

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
					sudo nixos-rebuild switch --flake ~/nixConfig/.#victus && \
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

}

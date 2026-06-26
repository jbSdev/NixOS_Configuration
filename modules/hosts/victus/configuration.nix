{ self, inputs, ...}: {

	flake.nixosModules.victusConfiguration = { pkgs, lib, ... }: {
		imports = [
			self.nixosModules.victusHardware
			self.nixosModules.nixPower
			self.nixosModules.nixSecurity
			self.nixosModules.nixConnections
			self.nixosModules.nixNvidia
			self.nixosModules.nixSpecialisations
			self.nixosModules.nixNixpkgs
			self.nixosModules.nixCorePkgs
            self.nixosModules.nixAudio
			self.nixosModules.nixHyprlandConfig
			self.nixosModules.nixDisplayManager
            self.nixosModules.nixGaming
            self.nixosModules.nixBrightness
            # self.nixosModules.nixSops
		];

		modules.hyprland.enable = true;

		nix.settings.experimental-features = [ "nix-command" "flakes" ];
		boot.loader.systemd-boot.enable = true;
		boot.loader.efi.canTouchEfiVariables = true;

		time.timeZone = "Europe/Warsaw";
		i18n.defaultLocale = "en_US.UTF-8";
		i18n.extraLocaleSettings = {
			LC_ADDRESS = "pl_PL.UTF-8";
			LC_IDENTIFICATION = "pl_PL.UTF-8";
			LC_MEASUREMENT = "pl_PL.UTF-8";
			LC_MONETARY = "pl_PL.UTF-8";
			LC_NAME = "pl_PL.UTF-8";
			LC_NUMERIC = "pl_PL.UTF-8";
			LC_PAPER = "pl_PL.UTF-8";
			LC_TELEPHONE = "pl_PL.UTF-8";
			LC_TIME = "pl_PL.UTF-8";
		};
		
		programs.zsh.enable = true;
		users.defaultUserShell = pkgs.zsh;

		users.users.jb = {
			extraGroups = [ "networkmanager" "wheel" ];
			uid = 1000;
			isNormalUser = true;
		};
        
        fonts.packages = with pkgs; [
            font-awesome
        ];

		system.stateVersion = "26.05";
	};

}

{ self, inputs, ... }: {

	flake.nixosModules.nixNixpkgs = { lib, ... }: {
		nixpkgs.config.allowUnfreePredicate = pkg: 
			builtins.elem (lib.getName pkg) [
				"nvidia-x11"
				"nvidia-settings"
                "steam"
                "steam-unwrapped"
			];

		nixpkgs.config.permittedInsecurePackages = [
			"librewolf-151.0.2-1"
			"librewolf-unwrapped-151.0.2-1"
		];
	};

}

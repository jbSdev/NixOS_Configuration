{ self, inputs, ...}: {
	
	flake.nixosConfigurations.victus = inputs.nixpkgs.lib.nixosSystem {
		system = "x86_64-linux";
		specialArgs = { inherit inputs; };
		modules = [
			self.nixosModules.victusConfiguration

			inputs.home-manager.nixosModules.home-manager

			{
				home-manager.useGlobalPkgs = true;
				home-manager.useUserPackages = true;
				home-manager.users.jb = import ../../../home/jb/default.nix;
                home-manager.backupFileExtension = "hp-backup";
                home-manager.extraSpecialArgs = {
                    inherit inputs;
                    firefox-addons = inputs.firefox-addons.packages.x86_64-linux;
                };
			}
		];
	};

}

{ self, inputs, ...}: {

	flake.nixosModules.nixCorePkgs = { pkgs, ... }: {
	
		environment.systemPackages = with pkgs; [
			gcc
			gnumake
			cmake
			pkg-config
			git
			busybox
			curl
			file
		];
	};

}

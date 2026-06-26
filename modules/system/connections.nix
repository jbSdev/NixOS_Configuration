{ self, inputs, pkgs, ... }: {

	flake.nixosModules.nixConnections = {
	
		networking = {
			hostName = "victus";
			networkmanager.enable = true;
			firewall = {
				enable = true;
				allowedUDPPorts = [ ];
				allowedTCPPorts = [ ];
			};
			nftables.enable = true;
		};

		# Bluetooth
		hardware.bluetooth = {
			enable = true;
			powerOnBoot = true;
			settings = {
				General = {
					AutoEnable = true;
					ControllerMode = "dual";
				};
			};
		};

		# Printing
		# services.printing.enable = true;
		# services.printing.drivers = with pkgs; [ gutenprint cups-bjnp ];
		# services.avahi = {
		# 	enable = true;
		# 	nssmdns4 = true;
		# 	openFirewall = true;
		# };

	};

}

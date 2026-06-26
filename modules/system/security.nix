{ self, inputs, ... }: {

	flake.nixosModules.nixSecurity = { pkgs, ... }: {
	
		# SSH
		services.openssh.enable = true;
		# services.openssh = {
		# 	enable = true;
		# 	ports = [ 12023 ];
		# 	settings = {
		# 		PasswordAuthentication = true;
		# 		AllowUsers = [ "jb" ];
		# 	};
		# };

		# GPG
		services.pcscd.enable = true;
		programs.gnupg.agent = {
			enable = true;
			pinentryPackage = pkgs.pinentry-gtk2;
			enableSSHSupport = true;
		};

	};

}

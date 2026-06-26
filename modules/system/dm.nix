{ self, inputs, ... }: {

	flake.nixosModules.nixDisplayManager = { pkgs, ... }: {
		# greetd + tuigreed - session picker
		services.greetd = {
			enable = true;
			settings = {
				default_session = {
					command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --asterisks";
				};
			};
		};
	};

}

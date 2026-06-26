{ self, inputs, ... }: {

	flake.nixosModules.nixPower = { pkgs, ... }: {

		powerManagement.enable = true;
		services.thermald.enable = true;

        environment.systemPackages = with pkgs; [
            linuxPackages.cpupower
            lm_sensors
            s-tui
        ];


		services.tlp = {
			enable = true;
			settings = {
				CPU_SCALING_GOVERNOR_ON_AC    = "performance";
				CPU_SCALING_GOVERNOR_ON_BET   = "powersave";

				CPU_ENERGY_PERF_POLICY_ON_AC  = "performance";
				CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

				CPU_MIN_PERF_ON_AC  = 0;
				CPU_MAX_PERF_ON_AC  = 100;
				CPU_MIN_PERF_ON_BAT = 0;
				CPU_MAX_PERF_ON_BAT = 40;

                CPU_BOOST_ON_AC = 1;
                CPU_BOOST_ON_BAT = 0;

                PLATFORM_PROFILE_ON_AC  = "performance";
                PLATFORM_PROFILE_ON_BAT = "low-power";
			};
		};
        
	};


}

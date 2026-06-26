{ self, inputs, ... }: {
	flake.nixosModules.nixNvidia = { config, pkgs, ... }: {

		# Wayland requirements
		boot.kernelParams = [
			"nvidia-drm.modeset=1"
			"nvidia-drm.fbdev=1"
		];

		services.xserver.videoDrivers = [ "nvidia" ];
		nixpkgs.config.nvidia.acceptLicense = true;

		hardware.nvidia = {
			modesetting.enable = true;
			powerManagement.enable = true;	# Wayland Suspend/Resume
			nvidiaSettings = true;
			package = config.boot.kernelPackages.nvidiaPackages.stable;

			# Open kernel module
			open = true;

			# Base Mode: Offload
			# IntelGPU handles general usage, NVIDIA GPU powers only on
			# selected, explicitly launched apps with `nvidia-offload`
			prime = {
				offload.enable = true;
				offload.enableOffloadCmd = true;
				sync.enable = false;
				intelBusId  = "PCI:0:2:0";
				nvidiaBusId = "PCI:1:0:0";
			};
		};

	};

}

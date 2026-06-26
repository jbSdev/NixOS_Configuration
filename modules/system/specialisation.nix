{ self, inputs, ...}: {

	flake.nixosModules.nixSpecialisations = {lib, ...}: {

		# Specialisations
		# Base config is using NVIDIA PRIME Offload
		# This profile is switching to PRIME Sync Mode - GPU always on
		specialisation = {
			performance.configuration = {
				system.nixos.tags = [ "performance" ];
				hardware.nvidia = {
					prime.offload.enable = lib.mkForce false;
					prime.offload.enableOffloadCmd = lib.mkForce false;
					prime.sync.enable = lib.mkForce true;
				};
			};
		};

	};

}

{ self, inputs, ...}: {

	flake.nixosModules.victusHardware = { config, lib, pkgs, modulesPath, ... }: {

	  imports =
	    [ (modulesPath + "/installer/scan/not-detected.nix")
	    ];
	
	  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
	  boot.initrd.kernelModules = [ ];
	  boot.kernelModules = [ "kvm-intel" ];
	  boot.extraModulePackages = [ ];
	
	  fileSystems."/" =
	    { device = "/dev/disk/by-uuid/e8a46f6d-5991-4fcf-9714-a40bf83b4601";
	      fsType = "ext4";
	    };
	
	  fileSystems."/boot" =
	    { device = "/dev/disk/by-uuid/7456-6B47";
	      fsType = "vfat";
	      options = [ "fmask=0077" "dmask=0077" ];
	    };
	
	  swapDevices = [ ];
	
	  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
	  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
	};

}

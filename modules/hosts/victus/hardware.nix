{ self, inputs, ...}: {

    flake.nixosModules.victusHardware = { config, lib, pkgs, modulesPath, ... }: {

        imports =
            [ (modulesPath + "/installer/scan/not-detected.nix")
            ];

        boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
        boot.initrd.kernelModules = [ ];
        boot.kernelModules = [ "kvm-intel" ];
        boot.extraModulePackages = [ ];

        # fileSystems."/" =
        #   { device = "/dev/disk/by-uuid/e8a46f6d-5991-4fcf-9714-a40bf83b4601";
        #     fsType = "ext4";
        #   };

        boot.initrd.luks.devices.cryptroot = {
            device = "/dev/disk/by-uuid/ce1a1dc1-53fe-4971-8865-f1ef8147d932";
            allowDiscards = true;      # keep SSD TRIM working
            bypassWorkqueues = true;   # lower latency on NVMe
        };

        fileSystems."/" =
            { device = "/dev/mapper/cryptroot";
                fsType = "ext4";
            };

        fileSystems."/boot" =
            { device = "/dev/disk/by-uuid/7456-6B47";
                fsType = "vfat";
                options = [ "fmask=0077" "dmask=0077" ];
            };

        # New random key every boot. PARTUUID, not UUID: the content (and so
        # the filesystem UUID) is recreated on every boot.
        swapDevices = [{
            device = "/dev/disk/by-partuuid/11a4110a-9be7-4c5a-906b-3050b6bb6d04";
            randomEncryption.enable = true;
        }];
        # Today the swap partition is picked up automatically by systemd's
        # GPT auto-generator (that's why it is active with swapDevices = []).
        # Turn that off so it can't try to use the raw partition unencrypted.
        boot.kernelParams = [ "systemd.gpt_auto=0" ];

        nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };

}

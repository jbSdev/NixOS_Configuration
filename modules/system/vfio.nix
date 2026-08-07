{ self, ... }: {

    flake.nixosModules.GPUPassthrough = { config, lib, ... }: {

        options.modules.vfio = {
            enable = lib.mkEnableOption "VFIO PCI passthrough";

            pciIds = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [];
                description = "PCI vendor:device IDs bound to vfio-pci";
            };
        };

        config = lib.mkIf config.modules.vfio.enable {
            boot = {
                kernelModules = [
                    "vfio"
                    "vfio_pci"
                    "vfio_iommu_type1"
                ];

                initrd.kernelModules = [
                    "vfio"
                    "vfio_pci"
                    "vfio_iommu_type1"
                ];

                kernelParams = [
                    "intel_iommu=on"
                    "iommu=pt"
                    "vfio-pci.ids=${lib.concatStringsSep "," config.modules.vfio.pciId}"
                ];
            };

            virtualisation.libvirtd.qemu.ovmf.enable = true;
        };
    };

}

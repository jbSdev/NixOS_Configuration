{ self, inputs, ... }: {

    flake.nixosModules.nixVM = { ... }: {

        programs.virt-manager.enable = true;

        virtualisation = {
            libvirtd.enable = true;
            spiceUSBRedirection.enable = true;
        };

        users.users.jb.extraGroups = [ "libvirtd" "kvm" ];

        boot.kernelModules = [
            "kvm-intel"
            "vfio"
            "vfio_pci"
            "vfio_iommu_type1"
        ];

        # IOMMU options
        boot.kernelParams = [
            "intel_iommu=on"
        ];

    };

}

{ self, inputs, ... }: {

    flake.nixosModules.nixVM = { ... }: {

        programs.virt-manager.enable = true;

        virtualisation = {
            libvirtd.enable = true;
            libvirtd.qemu.runAsRoot = true;
            spiceUSBRedirection.enable = true;
        };

        networking.firewall.trustedInterfaces = [ "virbr0" ];

        users.users.jb.extraGroups = [ "libvirtd" "kvm" ];

        boot.kernelModules = [
            "kvm-intel"
        ];

    };

}

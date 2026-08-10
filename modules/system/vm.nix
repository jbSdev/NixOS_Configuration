{ self, inputs, ... }: {

    flake.nixosModules.nixVM = { pkgs, lib, ... }: {

        programs.virt-manager.enable = true;

        virtualisation = {
            libvirtd = {
                enable = true;
                qemu.runAsRoot = lib.mkDefault false;
            };
            # libvirtd.qemu.runAsRoot = true;
            spiceUSBRedirection.enable = lib.mkDefault false;
        };

        # networking.firewall.trustedInterfaces = [ "virbr0" ];

        users.users.jb.extraGroups = [ "libvirtd" "kvm" ];

        boot.kernelModules = [
            "kvm-intel"
        ];

        environment.systemPackages = with pkgs; [ passt ];

    };

}

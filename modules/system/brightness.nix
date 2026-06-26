{ self, inputs, ... }:
{

    flake.nixosModules.nixBrightness = { pkgs, ... }: {
    
        users.users.jb.extraGroups = [ "video" ];
        services.udev.packages = [ pkgs.brightnessctl ];
        environment.systemPackages = [ pkgs.brightnessctl ];

    };

}

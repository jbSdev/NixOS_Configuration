{ self, inputs, ... }:
{

    flake.nixosModules.nixGaming = { pkgs, ... }: {

        programs.gamemode.enable = true;
        users.users.jb.extraGroups = [ "gamemode" ];

        programs.steam = {
            enable = true;
            # remotePlay.openFirewall = true;
            dedicatedServer.openFirewall = true;

            # NVIDIA Offload Mode
            extest.enable = false;
            gamescopeSession.enable = false;
            extraCompatPackages = [];

            package = pkgs.steam.override {
                extraEnv = {
                    __NV_PRIME_RENDER_OFFLOAD = "1";
                    __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-GO";
                    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
                    __EGL_VENDOR_LIBRARY_FILENAMES = "${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json";
                };
            };
        };
        
        hardware.steam-hardware.enable = true;
    
    };

}

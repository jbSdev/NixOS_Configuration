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

        # PS5 Controller Support
        hardware.uinput.enable = true;
        services.udev.packages = with pkgs; [ game-devices-udev-rules sc-controller ];

        # Lutris, wrapped with the same NVIDIA offload env as Steam above.
        # legendary-gl gives Lutris's "Epic Games Store" source native (non-Wine)
        # login/sync; Ubisoft Connect and EA App have no Linux build, so those get
        # installed into a Lutris-managed Wine prefix via its own installer scripts
        # (winetricks covers the dependencies those scripts commonly pull in).
        environment.systemPackages = [
            pkgs.sc-controller

            (pkgs.symlinkJoin {
                name = "lutris-nvidia-offload";
                paths = [
                    (pkgs.lutris.override {
                        extraPkgs = pkgs: [ pkgs.legendary-gl pkgs.winetricks ];
                    })
                ];
                buildInputs = [ pkgs.makeWrapper ];
                postBuild = ''
                    wrapProgram $out/bin/lutris \
                        --set __NV_PRIME_RENDER_OFFLOAD 1 \
                        --set __NV_PRIME_RENDER_OFFLOAD_PROVIDER NVIDIA-GO \
                        --set __GLX_VENDOR_LIBRARY_NAME nvidia \
                        --set __EGL_VENDOR_LIBRARY_FILENAMES ${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json
                '';
            })
        ];

    };

}

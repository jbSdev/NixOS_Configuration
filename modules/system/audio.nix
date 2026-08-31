{ ... }:
{

    flake.nixosModules.nixAudio = { pkgs, ... }: {

        services.pulseaudio.enable = false;
        security.rtkit.enable = true;

        services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;

            wireplumber.extraConfig = {
                "51-audio-priority" = {
                    "monitor.alsa.rules" = [
                        {
                            matches = [{
                                    "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI1__sink";
                            }];
                            actions = {
                                "update-props" = { "priority.session" = 200; };
                            };
                        }
                    ];
                };
            };
        };

        users.users.jb.extraGroups = [ "audio" ];


    };

}

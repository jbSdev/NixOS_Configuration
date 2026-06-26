{ pkgs, ... }:
{

    imports = [ ./spotify-themes.nix ];

    programs.spotify-player = {
        enable = true;
        settings = {
            theme = "Piano";
            enable_audio_visualization = true;
        };
    };

}

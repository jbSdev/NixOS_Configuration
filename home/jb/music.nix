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

    services.playerctld.enable = true;      # Getting most recent active player for mpris (waybar music module)

    home.packages = with pkgs; [
        mixxx
    ];
}

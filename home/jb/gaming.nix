{ pkgs, ... }:{

    home.packages = with pkgs; [
        steam
        steam-run
        protonup-qt
        prismlauncher
    ];

}

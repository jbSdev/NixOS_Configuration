{ config, ... }:
{

    programs.eww.enable = true;

    xdg.configFile."eww".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixConfig/assets/eww";

}

{ pkgs, firefox-addons, ... }:
{
	programs.firefox = {
		enable = true;
        nativeMessagingHosts = [ pkgs.passff-host ];
        profiles = {
            default.extraConfig = builtins.readFile ../../assets/user.js;
            default = {
                isDefault = true;
                extensions.packages = [
                    firefox-addons.passff
                ];
            };
        };
	};
}

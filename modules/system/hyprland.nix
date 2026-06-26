{ self, inputs, lib, ...}: {

	flake.nixosModules.nixHyprlandConfig = { config, lib, pkgs, ... }: {
		options.modules.hyprland.enable = lib.mkEnableOption "Hyprland compositor";

		config = lib.mkIf config.modules.hyprland.enable {
			programs.hyprland = {
				enable = true;
				xwayland.enable = true;
			};

			xdg.portal = {
				enable = true;
				extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
			};

		};
	};

}

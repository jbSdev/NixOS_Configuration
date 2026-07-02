{
	description = "jb NixOS Config";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

		flake-parts.url = "github:hercules-ci/flake-parts";
		import-tree.url = "github:vic/import-tree";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
        rose-pine-hyprcursor = {
            url = "github:ndom91/rose-pine-hyprcursor";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        sops-nix.url = "github:mic92/sops-nix";
        nixos-neovim = {
            url = "github:jbSdev/NixOS_neovim/Nix-managed";     # My own Neovim config
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nur = {
            url = "github:nix-community/NUR";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        firefox-addons = {
            url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
            inputs.nixpkgs.follows = "nixpkgs";
        };
	};

	outputs = inputs: inputs.flake-parts.lib.mkFlake 
		{inherit inputs;} (inputs.import-tree ./modules );
}

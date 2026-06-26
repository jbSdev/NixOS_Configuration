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
		nvim-config = {
			url = "github:jbSdev/NixOS_neovim";
			flake = false;
		};
        rose-pine-hyprcursor = {
            url = "github:ndom91/rose-pine-hyprcursor";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        sops-nix.url = "github:mic92/sops-nix";
	};

	outputs = inputs: inputs.flake-parts.lib.mkFlake 
		{inherit inputs;} (inputs.import-tree ./modules );
}

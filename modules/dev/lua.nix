{ ... }:
{
	perSystem = { pkgs, ... }: {
		devShells = {
			lua = pkgs.mkShell {
				name = "lua";
				packages = with pkgs; [ lua lua-language-server ];
				shellHook = ''
					echo "Lua shell loaded"
				'';
			};
		};
	};
}

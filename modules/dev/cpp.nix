# cpp.nix 
{ ... }:
{
	perSystem = { pkgs, ... }:
	let
		packs = with pkgs; [ gcc clang-tools cmake gnumake pkg-config libgcc gdb asm-lsp ];
		cppShellHook = std: ''
			export CXXFLAGS="-std=c++${std} $CXXFLAGS"
			echo "C++${std} shell loaded"
		'';
	in
	{
		devShells = {

            c = pkgs.mkShell {
                name = "c";
                packages = packs;
                shellHook = ''
                    echo "C shell loaded"
                '';
            };

			cpp11 = pkgs.mkShell {
				name = "cpp11";
				packages = packs;
				shellHook = cppShellHook "11";
			};

			cpp23 = pkgs.mkShell {
				name = "cpp23";
				packages = packs;
				shellHook = cppShellHook "23";
			};

		};
	};
}

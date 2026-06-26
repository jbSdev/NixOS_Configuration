# cpp.nix 
{ ... }:
{
	perSystem = { pkgs, ... }:
	let
		cppPkgs = with pkgs; [ gcc clang-tools cmake gnumake pkg-config libgcc gdb asm-lsp ];
		cppShellHook = std: ''
			export CXXFLAGS="-std=c++${std} $CXXFLAGS"
			echo "C++${std} shell loaded"
		'';
	in
	{
		devShells = {

			cpp11 = pkgs.mkShell {
				name = "cpp11";
				packages = cppPkgs;
				shellHook = cppShellHook "11";
			};

			cpp23 = pkgs.mkShell {
				name = "cpp23";
				packages = cppPkgs;
				shellHook = cppShellHook "23";
			};

		};
	};
}

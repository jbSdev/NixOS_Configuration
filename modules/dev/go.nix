{ ... }: {
	perSystem = { pkgs, ... }: {
		devShells.go = pkgs.mkShell {
			name = "go";
			packages = with pkgs; [
				go
				gopls
				gotools
				go-tools
				golangci-lint
			];
			shellHook = ''
				export GOPATH="$PWD/.go"
				echo "Go dev shell"
			'';
		};
	};
}

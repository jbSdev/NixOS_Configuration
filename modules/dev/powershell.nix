{ ... }: {
	perSystem = { pkgs, ... }: {
		devShells.powershell = pkgs.mkShell {
			name = "powershell";
			packages = with pkgs; [
				powershell
			];
			shellHook = ''
				echo "PowerShell dev shell"
			'';
		};
	};
}

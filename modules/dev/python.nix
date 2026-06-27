{ ... }:
{

    perSystem = { pkgs, ... }: {
        devShells.python = pkgs.mkShell {
            name = "python";
            packages = with pkgs; [
                python3
                python3Packages.pip
                python3Packages.virtualenv
                ruff
                black
                mypy
                python-lsp-server
                numpy
            ];
            shellHook = ''
                echo "Python dev shell"
            '';
        };
    };

}

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
                python3Packages.python-lsp-server
                python3Packages.numpy
            ];
            shellHook = ''
                echo "Python dev shell"
            '';
        };
    };

}

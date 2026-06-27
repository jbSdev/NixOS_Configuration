{ ... }: {
    perSystem = { pkgs, ... }: {
        devShells.rust = pkgs.mkShell {
            name = "rust";
            packages = with pkgs; [
                rustup
                    cargo
                    rustfmt
                    clippy
                    rust-analyzer
                    pkg-config
            ];
            shellHook = ''
                echo "Rust dev shell"
            '';
        };
    };
 }

{ ... }:
{
    perSystem = { pkgs, ... }: {
        devShells.java = pkgs.mkShell {
            name = "java";
            packages = with pkgs; [ jdk maven gradle ant gdb ];
            shellHook = ''
                export JAVA_HOME="${pkgs.jdk}"
                echo "Java development shell loaded"
                echo "Java: $(java --version 2>&1 | head -n 1)"
            '';
        };
    };
}

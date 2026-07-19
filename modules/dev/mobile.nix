{ inputs, ... }:
{
    perSystem = { system, lib, ... }: {
        devShells.mobile =
            let
                # android-tools pulls in the unfree android-sdk-platform-tools
                # package; allow it only for this shell's own pkgs instance
                # rather than widening the allowlist for every devShell.
                pkgs = import inputs.nixpkgs {
                    inherit system;
                    config.allowUnfreePredicate = pkg:
                        builtins.elem (lib.getName pkg) [
                            "android-sdk-platform-tools"
                            "platform-tools"
                        ];
                };
            in
            pkgs.mkShell {
            name = "mobile";
            packages = with pkgs; [
                # Android
                android-tools
                adb-sync
                adbtuifm
                # iPhone
                # utm         # iOS emulator
                ifuse
            ];
			shellHook = ''
				echo "Android & iOS dev shell"
			'';
        };
    };
}

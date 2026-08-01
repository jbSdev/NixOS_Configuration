{ ... }:
{
    perSystem = { pkgs, ... }: {
        devShells.arduino = pkgs.mkShell {
            name = "arduino";
            packages = with pkgs; [
                arduino-cli
                arduino-language-server
                platformio
                esptool
                avrdude
                picocom
                clang-tools
            ];
            shellHook = ''
                export ARDUINO_DIRECTORIES_DATA="$PWD/.arduino15"
                export ARDUINO_DIRECTORIES_USER="$PWD/Arduino"
                export ARDUINO_DIRECTORIES_DOWNLOADS="$PWD/.arduino15/staging"
                echo "Arduino & ESP32 dev shell"
            '';
        };
    };
}

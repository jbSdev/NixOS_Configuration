{ self, inputs, ... }:
{

    flake.nixosModules.nixFonts = { pkgs, ... }: {

        fonts = {
            enableDefaultPackages = true;

            packages = with pkgs; [
                nerd-fonts.jetbrains-mono
                nerd-fonts.fira-code
                nerd-fonts.hack

                noto-fonts
                noto-fonts-cjk-sans
                noto-fonts-emoji

                jetbrains-mono
                fira-code
                fira-code-symbols

                monospace
            ];

            fontconfig = {
                defaultFonts = {
                    monospace = [ "JetBrainsMono Nerd Font" "JetBrainsMono" ];
                    sansSerif = [ "Noto Sans" ];
                    serif     = [ "Noto Serif" ];
                    emoji     = [ "Noto Color Emoji" ];
                };
            };
        };

    };

}

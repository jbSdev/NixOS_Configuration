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
                noto-fonts-color-emoji

                jetbrains-mono
                fira-code
                fira-code-symbols

                terminus_font_ttf
            ];

            fontconfig = {
                allowBitmaps = true;
                useEmbeddedBitmaps = true;
                defaultFonts = {
                    monospace = [ "JetBrainsMono Nerd Font" "JetBrains Mono" ];
                    # monospace = [ "Dina" ];
                    sansSerif = [ "Noto Sans" ];
                    serif     = [ "Noto Serif" ];
                    emoji     = [ "Noto Color Emoji" ];
                };
            };
        };

    };

}

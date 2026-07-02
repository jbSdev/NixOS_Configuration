{ self, inputs, ... }:
{

    flake.nixosModules.victusInput = { ... }: {

        services.libinput = {
            enable = true;
            touchpad = {
                naturalScrolling = true;        # invert scroll
                tapping = true;                 # tap to click
                scrollMethod = "twofinger";
            };
        };

    };

}

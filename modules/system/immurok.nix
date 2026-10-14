{ self, inputs, ... }: {

    flake.nixosModules.nixImmurok = {
        imports = [ inputs.immurok-nix.nixosModules.default ];

        # Base: sudo + polkit by touch (password fallback), SSH agent.
        # Login (greetd) stays password-only.
        services.immurok = {
            enable = true;
            screenUnlock.enable = true;     # addon: touch unlocks hyprlock
        };
    };
}

{ inputs, ... }:
{
    imports = [ inputs.immurok-nix.homeManagerModules.default ];

    programs.immurok = {
        enable = true;
        # gpg-agent keeps "*"; only GitHub signs with the key on the device.
        sshAgent.hosts = [ "github.com" ];
        hyprlock = {
            enable = true;
            idleLockMinutes = 10;
        };
        claudeCode.enable = true;   # using-imk skill; enforce would take over ~/.claude/settings.json
    };
}

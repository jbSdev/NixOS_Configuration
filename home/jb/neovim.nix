{ inputs, ... }:
{
    imports = [ inputs.nixos-neovim.homeManagerModules.default ];
}

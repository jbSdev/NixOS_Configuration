{ inputs, ... }:
{
    imports = [ inputs.sops-nix.homeManagerModules.sops ];
    sops.defaultSopsFile = ../../secrets.yaml;
    sops.defaultSopsFormat = "yaml";
    sops.age.keyFile = "/home/jb/.config/sops/age/keys.txt";
}

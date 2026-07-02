# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal NixOS flake configuration for a single host (`victus`, HP Victus laptop, x86_64-linux). Uses `flake-parts` for flake structure and `import-tree` to auto-load all `.nix` files under `modules/` — no manual imports needed in `flake.nix`.

## Key Commands

```bash
# Rebuild and switch the system
sudo nixos-rebuild switch --flake ~/nixConfig/.#victus
# (aliased as `rebuild` in zsh)

# Update flake inputs
nix flake update

# Update only the neovim input and rebuild
sudo nix flake lock --update-input nixos-neovim && sudo nixos-rebuild switch --flake ~/nixConfig/#.victus
# (aliased as `rebuild-nvim`)

# Enter a dev shell
nix develop .#python   # or: cpp11, cpp23, lua, rust, go, powershell
# (also available via the `dev <name>` zsh function)

# Edit sops secrets
sops secrets.yaml
```

## Repository Structure

```
flake.nix              # Entry point; delegates to flake-parts + import-tree
modules/
  parts.nix            # Declares supported systems (x86_64-linux)
  hosts/victus/
    default.nix        # Assembles flake.nixosConfigurations.victus; wires home-manager
    configuration.nix  # Imports all system nixosModules for victus
    hardware.nix       # Hardware scan output
  system/              # Each file exposes a flake.nixosModules.<name>
    nixpkgs.nix        # Unfree allowlist, NUR overlay, insecure packages
    security.nix       # SSH, GPG/pcscd, sops-nix system config
    nvidia.nix, hyprland.nix, gaming.nix, audio.nix, ...
  dev/                 # perSystem devShells (cpp11, cpp23, lua, python, rust, go, powershell)
home/jb/
  default.nix          # Home-manager root: packages, zsh, SSH, GPG agent, XDG config
  hyprland.nix         # Hyprland WM config
  binds.nix            # Keybindings
  neovim.nix           # Imports nixos-neovim home-manager module
  git.nix              # Git config
  pass.nix             # password-store + GPG key import via sops activation
  sops.nix             # sops-nix home-manager module config
  firefox.nix          # Firefox with NUR addons
  gaming.nix, music.nix, spotify-themes.nix
assets/
  user.js              # Firefox user preferences (copied via home-manager)
  wallpaper.jpg
secrets.yaml           # sops-encrypted secrets (age)
.sops.yaml             # age key config for sops
```

## Architecture Notes

- **`import-tree`**: Every `.nix` file dropped into `modules/` is automatically picked up. New modules don't need to be registered anywhere.
- **Module exposure pattern**: System modules use `flake.nixosModules.<name>` (e.g. `nixSecurity`, `nixNixpkgs`) and are assembled by `modules/hosts/victus/configuration.nix` via `imports`.
- **Home-manager**: Runs as a NixOS module, not standalone. Config root is `home/jb/default.nix`; passed via `home-manager.users.jb`.
- **Custom module options**: Some modules use `modules.<name>.enable = true` (e.g. `modules.neovim.enable`, `modules.hyprland.enable`) — implemented via `wrapper-modules` from BirdeeHub.
- **Neovim**: Config comes from an external flake (`github:jbSdev/NixOS_neovim/Nix-managed`) mounted as a home-manager module and also symlinked raw (`nvim-config` input → `~/.config/nvim`).
- **Secrets**: `sops-nix` with age. Key lives at `~/.config/sops/age/keys.txt`. Both system (`modules/system/security.nix`) and home-manager (`home/jb/sops.nix`) import sops-nix modules.
- **Unfree/insecure packages**: Allowlisted in `modules/system/nixpkgs.nix`. Add new ones there.
- **Firefox addons**: Sourced from `gitlab:rycee/nur-expressions` (not NUR) via the `firefox-addons` flake input, passed as `extraSpecialArgs`.

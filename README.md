# Nix Dev Setup

Home Manager configuration for the `hogan` user environment on NixOS.

## Usage

```bash
just switch
```

Or directly:

```bash
nix run home-manager/release-25.11 -- switch --flake .
```

## Structure

```
.
├── flake.nix    # Flake entry point
├── home.nix     # All user configuration
└── justfile     # Common tasks
```

## System Config

System-level config (boot, desktop, network, services) lives in `/etc/nixos/`.

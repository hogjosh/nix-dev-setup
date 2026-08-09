# Nix development environment

This repository defines the Home Manager profile for the `hogan` user on
`x86_64-linux`. It is a user-environment configuration: development tools,
shell and Git defaults, terminal settings, and Neovim configuration live here.
It does not manage NixOS system settings.

## Apply the configuration

From the repository root, run:

```bash
just switch
```

This invokes Home Manager 25.11 through Nix and applies the `hogan` profile in
the current checkout. To use a Nix binary at its standard system location,
use `just switch-abs` instead.

The resulting environment includes a `hs` Zsh alias for applying this checkout
with the installed `home-manager` command. The `hu` alias updates flake inputs
before applying; use it intentionally, since it changes `flake.lock`.

## Validate changes

Evaluate the flake without writing a lock file:

```bash
nix flake show --no-write-lock-file
nix eval .#homeConfigurations.hogan.config.home.username --raw --no-write-lock-file
```

`just check` is a post-activation smoke check for selected installed commands.
It is not a complete configuration test.

## Repository map

| Path | Responsibility |
| --- | --- |
| `flake.nix` | Declares pinned inputs and exports the `hogan` Home Manager configuration. |
| `flake.lock` | Records the exact input revisions. Change it only as part of an intentional input update. |
| `home.nix` | Defines packages, shell, Git, terminal, Direnv, Starship, and managed configuration files. |
| `justfile` | Provides shortcuts for applying and smoke-checking the profile. |
| `nvim/` | Neovim configuration symlinked to `~/.config/nvim` by Home Manager. |
| `AGENTS.md` | Repository-specific instructions for people and coding agents making changes. |

## Neovim

Neovim uses LazyVim with `lazy.nvim`; its first launch may clone plugin
dependencies into Neovim's data directory. Project-owned settings and plugin
specifications are in [`nvim/`](nvim/README.md).

## Scope and safety

Keep NixOS-level configuration—such as boot, networking, desktop services, and
system packages—in the system configuration (commonly `/etc/nixos/`), not in
this repository. Do not casually change `home.stateVersion`, the target user,
or the target architecture: they describe the existing deployed profile rather
than an upgrade preference.

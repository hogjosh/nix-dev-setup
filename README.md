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

Evaluate the locked flake without building, activating, or writing a lock file:

```bash
just validate
```

`just check` runs that evaluation and then smoke-checks selected installed
commands. It is intended for an already activated profile, not as a complete
test suite.

Use `just codex-update` to refresh the latest npm release of Codex without
updating unrelated Nix inputs or packages.

To update Nix-managed software, review the lockfile diff and run either
`just update` for every input or `just update-input <name>` for one input (for
example, `just update-input nixpkgs`). Both commands change `flake.lock` and
apply the resulting profile, so use them deliberately.

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

## Toolchain ownership

Use Home Manager for tools needed consistently across this machine. This
includes Node.js 24, development utilities, and the command-line applications
listed in `home.nix`. Mise remains available for project-specific version
requirements and owns one intentional global exception: the latest npm release
of Codex. This keeps Codex current independently of the Nixpkgs pin without a
hand-managed global npm install. After applying a change to this profile, run
`mise install` to install declared Mise tools. Prefer a project-local
`mise.toml` for every other runtime version that differs from this profile.

Nix development uses the `nixd` language server, `nixfmt` formatter, and
`statix` linter. Neovim is configured to use `nixd` for Nix files.

The profile also provides CMake and Difftastic. Run `git difft` for an opt-in,
language-aware structural diff; ordinary `git diff` continues to use Delta.

## Scope and safety

Keep NixOS-level configuration—such as boot, networking, desktop services, and
system packages—in the system configuration (commonly `/etc/nixos/`), not in
this repository. Do not casually change `home.stateVersion`, the target user,
or the target architecture: they describe the existing deployed profile rather
than an upgrade preference.

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

## Nix storage cleanup

Home Manager runs Nix garbage collection weekly, deleting this user's profile
generations older than 30 days before reclaiming unreferenced store paths. This
keeps a month of rollback history. To run the scheduled cleanup early, use:

```bash
systemctl --user start nix-gc.service
```

Inspect its next run with `systemctl --user list-timers nix-gc.timer`. Before
using a more aggressive retention period, review `nix-env --list-generations`
and remember that Nix GC does not remove non-Nix data such as Steam content,
project assets, or application caches.

## Repository map

| Path | Responsibility |
| --- | --- |
| `flake.nix` | Declares pinned inputs and exports the `hogan` Home Manager configuration. |
| `flake.lock` | Records the exact input revisions. Change it only as part of an intentional input update. |
| `home.nix` | Defines packages, shell, Git, terminal, Direnv, Starship, and managed configuration files. |
| `plasma.nix` | Defines per-user KDE Plasma input preferences. |
| `herdr/config.toml` | Placeholder for durable Herdr preferences; it currently preserves Herdr's built-in defaults. |
| `kitty/kitty.conf` | Shared Kitty terminal preferences, including the installed Hack Nerd Font and font size. |
| `justfile` | Provides shortcuts for applying and smoke-checking the profile. |
| `nvim/` | Neovim configuration symlinked to `~/.config/nvim` by Home Manager. |
| `zellij/config.kdl` | Shared Zellij configuration deployed to `~/.config/zellij/config.kdl`. |
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

Direnv uses `nix-direnv` for cached project environments. Activation keeps its
environment-diff output quiet and warns only after a 30-second evaluation. Its
Zsh hook, like Starship's, is initialized by Home Manager.

The managed session sets `LESS` so color-capable pager output remains visible
after exit and short output does not open a pager.

The profile also provides CMake and Difftastic. Run `git difft` for an opt-in,
language-aware structural diff; ordinary `git diff` continues to use Delta.

Herdr is installed as an agent-aware terminal multiplexer. Its configuration is
managed at `~/.config/herdr/config.toml`; it currently contains no overrides,
so Herdr uses its built-in defaults. Launch `herdr` from a project when you
want a session. It starts and restores its own session server, so the profile
does not create an empty Herdr service at boot.

It also includes `mosh`, `tmux`, `moshi-hook`, `ffmpeg`, and the Hugging Face
`hf` CLI. `moshi-hook` runs as a restarting user service; enable user lingering
once with `loginctl enable-linger hogan` to have it start before login and keep
running after logout. After applying the profile, pair it with the token from
Moshi and install agent hooks:

```bash
moshi-hook pair --token <token-from-Moshi>
moshi-hook install
systemctl --user restart moshi-hook.service
```

The pairing token and Moshi-owned settings remain local in
`~/.config/moshi/config.toml` and are intentionally not managed by this
repository. To connect Codex state to both Herdr and Moshi, run this one-time
setup after both tools are installed:

```bash
herdr integration install codex
moshi-hook install --target codex
```

These commands manage their respective hook entries in `~/.codex`; keep those
mutable tool-owned files outside this repository. Kitty uses the managed Hack
Nerd Font at 15 pt. To change its persistent font or size, edit
`kitty/kitty.conf`, run `just switch`, and restart Kitty.

Kitty starts new windows at an exact 120 by 35 character grid instead of
remembering the previous pixel dimensions. On Plasma Wayland, Kitty cannot
snap manual resizing to character-cell boundaries; any leftover pixels are
kept at the bottom and right edges rather than forming a centered border.

## Remote desktop

Plasma's KRDP server starts with the logged-in `hogan` Plasma session and
shares it over RDP on port 3389. It uses the existing Linux account password;
its self-signed TLS certificate and private key are generated locally under
`~/.local/share/krdpserver/` and are not repository state. Connect from a Mac
with Windows App using `192.168.1.50:3389` and username `hogan`.

KRDP cannot access the SDDM login screen. Use SSH for reboot and recovery.
The NixOS firewall must allow TCP 3389; keep RDP on the LAN or behind a private
network such as Tailscale, never a public router port-forward.

Git uses the personal `josh.hogan@me.com` identity, rebases pulls, and uses
Delta by default. `git alias-main` is an opt-in helper for repositories whose
remote still uses `master`; it creates local `main` aliases without changing
the remote.

Starship shows a snowflake segment while a Nix shell or Devenv environment is
active, making project-scoped toolchains visible in the prompt.

KDE Plasma settings are managed separately in `plasma.nix`. The keyboard uses
a 300 ms repeat delay and 25 repeats per second. The Logitech MX Ergo uses
pointer speed `0.40` with the no-acceleration profile. Add other confirmed
desktop preferences there rather than changing NixOS system configuration.

## Scope and safety

Keep NixOS-level configuration—such as boot, networking, desktop services, and
system packages—in the system configuration (commonly `/etc/nixos/`), not in
this repository. Do not casually change `home.stateVersion`, the target user,
or the target architecture: they describe the existing deployed profile rather
than an upgrade preference.

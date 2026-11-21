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

This invokes this flake's pinned Home Manager input through Nix and applies
the `hogan` profile in the current checkout. To use a Nix binary at its
standard system location, use `just switch-abs` instead.

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

Codex is declared as `"npm:@openai/codex" = "latest"` in the Mise configuration
managed by `home.nix`. Mise uses the latest installed version until you
explicitly upgrade it:

```bash
just update-codex
```

This runs `mise upgrade --no-prune npm:@openai/codex` and prints the resulting
version. Mise resolves and installs the newest release; older installs stay
available for running sessions. No Nix rebuild or repository change is needed.
Start a new Codex session to use the updated CLI. Declaring `latest` does not
schedule automatic upgrades; see [Mise's version behavior](https://mise.jdx.dev/faq.html#does-latest-mean-the-newest-release).

Home Manager disables Codex's startup update checks and in-app updates by
merging `check_for_update_on_startup = false` and
`features.in_app_updates = false` into the mutable `~/.codex/config.toml`,
preserving other settings and comments. Codex's own updater stays disabled.
See the [official configuration reference](https://developers.openai.com/codex/config-reference/).

The managed Zsh alias runs `codex --no-daemon`, keeping interactive Codex
sessions attached to their terminal without the shared background server.
Additional arguments are passed through, for example `codex resume`.

To update Nix-managed software, review the lockfile diff and run either
`just update` for every input or `just update-input <name>` for one input (for
example, `just update-input nixpkgs`). Both commands change `flake.lock` and
apply the resulting profile, so use them deliberately.

Lutris and its bundled umu environment come from this profile's Nixpkgs
input. AMD's kernel driver, Mesa (including 32-bit support), firmware, and
the Nix daemon belong to the separate stable NixOS flake in `/etc/nixos`.
Updating this Home Manager profile does not update those system components.
For a system refresh, update that flake's `nixpkgs` input, build
`nixosConfigurations.anvil.config.system.build.toplevel`, then run
`sudo nixos-rebuild boot --flake /etc/nixos#anvil` to select it for the next
boot. Reboot when ready; the boot menu retains previous generations for
rollback. Keep the working Battle.net/WoW prefix and selected Proton runner
local to Lutris rather than recreating them during a package update.

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

Lutris includes umu in its compatibility environment for Proton-based
Battle.net and WoW installations. After changing that environment, close and
reopen Lutris before retrying an installer. `umu-run` is also available directly
from the Home Manager profile.

Use Home Manager for tools needed consistently across this machine. This
includes Node.js 24, development utilities, and the command-line applications
listed in `home.nix`. Three stateful, fast-moving tools are deliberate exceptions:
Mise owns the latest installed npm release of Codex. Herdr Core's official
installer owns `~/.local/bin/herdr-core` and its `hc` alias, allowing its updater to preserve
running terminals. Moshi Hook's official installer owns `~/.local/bin/moshi-hook`
and its `moshi` alias so the iOS app can update it in place; Home Manager still
owns its user service. After applying a change to this profile, run
`mise install` to install declared Mise tools. Prefer a
project-local `mise.toml` for every other runtime version that differs from
this profile.

Nix development uses the `nixd` language server, `nixfmt` formatter, and
`statix` linter. Neovim is configured to use `nixd` for Nix files.

Direnv uses `nix-direnv` for cached project environments. Activation keeps its
environment-diff output quiet and warns only after a 30-second evaluation. Its
Zsh hook, like Starship's, is initialized by Home Manager.

The managed session sets `LESS` so color-capable pager output remains visible
after exit and short output does not open a pager.

The profile also provides CMake and Difftastic. Run `git difft` for an opt-in,
language-aware structural diff; ordinary `git diff` continues to use Delta.

[Herdr Core](https://github.com/herdrdev/herdr-core) runs persistent terminals
and coding agents through the `hc` CLI. Its official installer places
`herdr-core` in `~/.local/bin` and adds an `hc` alias when that name is available.
Home Manager keeps that directory on `PATH` but does not own the binary.
Install or repair the current release with:

```bash
curl -fsSL https://releases.herdr.dev/core/install.sh | sh
hc --version
```

Update with `hc update`; running Core terminals survive the update. Start a
shell from a project with `hc run --bg --keep --name work`, list terminals with
`hc ls`, and attach with `hc attach work`. Detach with `Ctrl+\`.
`--keep` recreates a fresh shell when Core recovers a lost program, including
after a reboot; it does not resume the previous agent. Run `hc --skill` for
the installed version's agent manual.

Core reads optional local settings from `~/.config/herdr-core/config.toml`.
The profile uses its defaults and does not seed a configuration or start a
Core service at boot. Core replaces the old Herdr TUI workflow; its terminals
and settings are separate. Recreate needed sessions in Core and retire the
old `~/.local/bin/herdr` binary after leaving those sessions. The previous
`~/.config/herdr` directory is no longer managed or used by this profile.

The Studio Mac is registered in Core's local machine state as `studio`, using
the verified SSH target `hogan@192.168.1.161`. Home Manager does not recreate
this registration: Core has no machine-list setting in its configuration and
writes learned remote IDs and versions to its mutable `machines.json` under
`~/.local/state/herdr-core`. Keep that registry Core-owned rather than linking
it into the Nix store. Check `hc machine ls` first; if the entry is missing, add
it with `hc machine add hogan@192.168.1.161 --name studio`. Core uses the
existing remote installation and SSH authentication. See the
[machine connection guide](https://github.com/herdrdev/herdr-core/blob/master/docs/machines.md).

Run a command there with `hc exec --on studio /usr/bin/sw_vers`. For an
interactive remote shell:

```bash
hc run --bg --on studio --cwd /Users/hogan --name work
hc attach studio/work
```

Detach with `Ctrl+\`; the shell keeps running on the Mac. If the Mac's address
changes, update its local Core registration. Keep SSH keys and Core's mutable
machine state outside this repository.

Moshi opens Core through its own `moshi-hook hc attach` bridge. On Anvil,
the default core needs a local terminal to show; terminals from the registered
Studio machine alone do not supply one. If connecting immediately exits after
a reboot, check `hc server status` and `hc ls`. When there are no local
terminals, create one with `hc run --bg --keep --name work --cwd /home/hogan`,
then reconnect to the default Herdr Core session in Moshi. Check the bridge
from an interactive terminal with `moshi-hook hc attach --session default`.
Keep these shells in Core's runtime state rather than a Home Manager service.

The profile also includes `mosh`, `tmux`, Pangolin Newt, `ffmpeg`, and the
Hugging Face `hf` CLI. `moshi-hook` and Newt run as restarting user services;
enable user lingering once with `loginctl enable-linger hogan` to have them
start before login and keep running after logout. Install Moshi Hook with its
[official installer](https://getmoshi.app/docs/install-moshi-hook), skipping
its service installer because Home Manager owns the unit. Skip the first-run
prompt to preserve existing local preferences:

```bash
curl -fsSL https://getmoshi.app/install.sh | MOSHI_HOOK_SKIP_SERVICE=1 MOSHI_HOOK_SKIP_FIRST_RUN=1 sh
```

Apply the profile with `just switch`. On a new host, pair Moshi Hook with the
token from Moshi, install agent hooks, and restart the service:

```bash
moshi-hook pair --token <token-from-Moshi>
moshi-hook install
systemctl --user restart moshi-hook.service
```

The updater replaces its executable in place, which fails with a read-only
filesystem error when the executable lives in `/nix/store`.
When migrating from the previous Nix package, run `moshi-hook install` once
after installing the writable binary to replace agent hooks that still point
into `/nix/store`. Pairing survives; no new token is needed. Do not run
`moshi-hook service install`, which would overwrite the Home Manager unit.

To update from the iOS app, connect to this host over SSH, open Home → Hooks,
select the host, and use its update action. Under Options → Install updates,
choose Ask for one-tap updates, Auto for automatic installation, or Off to stop
checking. The existing local preference is preserved. Per Moshi's
[update settings](https://getmoshi.app/docs/hook-settings), the daemon checks
every six hours and automatic updates wait until pending approvals clear.
Both the daemon and generated hooks use the stable writable binary path, so
later Home Manager activations do not downgrade app-installed updates.

Manual updates use `moshi-hook update`, followed by
`systemctl --user restart moshi-hook.service`. Run `moshi-hook --version` and
`moshi-hook doctor` to verify the installed CLI and running daemon. The CLI
equivalents of the app's update choices are `moshi-hook set auto-update ask`,
`moshi-hook set auto-update auto`, and `moshi-hook set auto-update off`.

The pairing token and Moshi-owned settings remain local in
`~/.config/moshi/config.toml` and are intentionally not managed by this
repository. To connect Codex to Moshi, run this one-time setup after both
tools are installed:

```bash
moshi-hook install --target codex
```

This command manages Moshi's hook entries in `~/.codex`; keep those mutable
tool-owned files outside this repository. Core uses status reported by agents
through OSC 7501 and does not use the old `herdr integration install codex`
workflow. Kitty uses the managed Hack Nerd Font at 15 pt. To change its
persistent font or size, edit
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

On AC power, the display turns off after 15 minutes of inactivity while the
machine stays awake. Automatic screen locking (including on resume), AC
idle-suspend, and idle dimming are disabled in `plasma.nix`. Manual screen
locking still works, but a manually locked session must be unlocked before
KRDP can share the desktop again.

## Pangolin site connector

Anvil runs the pinned Newt 1.19.0 binary as the Home Manager-managed
`newt.service` user unit and connects to `https://pangolin.hogan.lol`. The
service is enabled but remains stopped until its machine-local credentials
exist. Create an Anvil site in Pangolin, then write only the generated values
to `~/.config/newt/newt.env` without placing them in this checkout:

```text
NEWT_ID=<generated-Newt-ID>
NEWT_SECRET=<generated-site-secret>
```

`NEWT_ID` is the connector credential identifier, not the site's stable
`niceId`. Separately record and report the non-secret site `niceId` for the
homelab blueprints that declare Anvil's Pangolin resources.

Restrict that file to the account, restart the unit, and inspect its status:

```bash
install -d -m 700 ~/.config/newt
umask 077
$EDITOR ~/.config/newt/newt.env
chmod 600 ~/.config/newt/newt.env
systemctl --user restart newt.service
systemctl --user status newt.service
```

Do not add the endpoint to the credential file; Home Manager declares it in
the unit. Do not commit the Newt ID or secret. The NixOS system configuration
continues to own OpenSSH and the firewall: TCP 22 is open, and UDP 60000-61000
is open for Mosh. The homelab configuration owns Pangolin resources, so do not
create SSH or Mosh resources manually in the dashboard.

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

The 2026-10-23 coordinated Pangolin update pins Newt 1.19.0. Its official
Linux amd64 release checksum was independently verified before activation.
Keep connector credentials in the existing machine-local environment file.

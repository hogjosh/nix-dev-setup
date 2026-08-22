# Repository guidance

## What this repository manages

This is a single-user Home Manager configuration for `hogan` on
`x86_64-linux`. `flake.nix` assembles inputs and exports
`homeConfigurations.hogan`; `home.nix` is the primary configuration module.
The `nvim/` directory is deployed as `~/.config/nvim`.

Do not add NixOS system configuration here. Do not change `home.username`,
`home.homeDirectory`, `home.stateVersion`, or the target system unless the task
explicitly calls for a migration.

## Change discipline

- Keep related configuration in `home.nix`; add a new module only when it gives
  a clear boundary and wire it into `flake.nix`.
- Treat `flake.lock` as generated, pinned dependency state. Update it only for
  an intentional input update, and review the resulting diff.
- Keep local Neovim customizations under `nvim/lua/config/` or
  `nvim/lua/plugins/`. `example.lua` is disabled documentation, not active
  configuration. `nvim/lua/plugins/nix.lua` selects the Nix-provided `nixd`
  language server over LazyVim's alternative `nil_ls` server.
- The Nix-managed Neovim base may load optional machine-local overrides from
  `~/.config/nvim-local`. Keep durable cross-machine settings in this
  repository; use that external path only for private or machine-specific
  additions.
- `plasma.nix` owns per-user KDE Plasma preferences. Keep it narrow and add a
  setting only after its desired value is known; do not put Plasma preferences
  in NixOS system configuration.
- KRDP is a user service declared in `home.nix`. It shares only an existing
  Plasma session and uses the Linux account password; never commit its
  generated TLS key or introduce a repository-stored remote-desktop password.
- Pangolin Newt is a user service declared in `home.nix`. Keep its official
  Linux binary version and endpoint declarative, but keep the generated Newt ID
  and secret only in `~/.config/newt/newt.env`. The non-secret site `niceId` is
  a separate stable identifier; report it for homelab blueprints. Do not create
  Pangolin resources manually; the homelab configuration owns those resources.
- Keep shared Zellij behavior in `zellij/config.kdl`, not as an inline Nix
  string. Preserve the minimal configuration until a deliberate keybinding or
  layout workflow is chosen.
- Keep shared Kitty preferences in `kitty/kitty.conf`, not as an inline Nix
  string. The required Nerd Font belongs in `home.packages` beside Kitty.
- Put machine-wide command-line tools and runtimes in `home.packages`. Retain
  Mise for project-specific versions and runtimes not available at a suitable
  version from this flake's pinned Nixpkgs. The sole global Mise tool is the
  latest npm-backed Codex CLI; do not add other global Mise tools without a
  clear versioning reason.
- `git difft` is an opt-in structural diff backed by Difftastic. Keep Delta as
  the default Git pager unless a task explicitly changes that preference.
- Git uses the personal identity and portable settings shared with the Studio
  Mac. Do not add macOS Keychain or Kaleidoscope integration here; do not add
  a blanket `.vscode/` global ignore, because projects may intentionally track
  VS Code workspace settings.
- Direnv uses `nix-direnv` and suppresses routine environment-diff output;
  retain its 30-second evaluation warning and Home Manager-managed Zsh hook
  unless project workflows require a different threshold.
- Do not commit generated Home Manager results, Neovim plugin state, or local
  secrets. Put machine-local shell settings in the already-supported
  `~/.config/env/local.sh` file instead of this repository.
- Preserve unrelated working-tree changes. This configuration is normally
  applied on the user's live machine, so make small, reviewable edits.
- Keep documentation and agent guidance aligned with the configuration and
  workflows they describe. Commit completed work as small, logical, atomic
  commits rather than accumulating unrelated changes.

## Verify before handoff

Run the checks that fit the change:

```bash
nixfmt flake.nix home.nix
stylua nvim
just validate
```

Formatting tools are installed by this profile and may not be available before
the first activation. `just check` verifies selected commands after activation;
it first evaluates the Home Manager configuration. After changing the Mise
declaration, apply the profile and run `mise install`. Apply only when the task
requires it:

```bash
just switch
```

`just update` and `just update-input <name>` both modify `flake.lock` and
apply the profile. Do not run them unless an intentional dependency update is
in scope.

## Documentation

Keep `README.md` focused on operating the Home Manager profile and
`nvim/README.md` focused on the deployed Neovim configuration. Update the
relevant document whenever a user-facing workflow, managed path, or repository
layout changes.

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
  configuration.
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
nix flake show --no-write-lock-file
nix eval .#homeConfigurations.hogan.config.home.username --raw --no-write-lock-file
```

Formatting tools are installed by this profile and may not be available before
the first activation. `just check` verifies selected commands after activation;
it does not evaluate the Home Manager configuration. Apply only when the task
requires it:

```bash
just switch
```

## Documentation

Keep `README.md` focused on operating the Home Manager profile and
`nvim/README.md` focused on the deployed Neovim configuration. Update the
relevant document whenever a user-facing workflow, managed path, or repository
layout changes.

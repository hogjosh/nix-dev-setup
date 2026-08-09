# Neovim configuration

This directory is managed by Home Manager as `~/.config/nvim`. It uses
LazyVim, bootstrapped through `lazy.nvim` in `init.lua` and
`lua/config/lazy.lua`.

## Layout

| Path | Responsibility |
| --- | --- |
| `init.lua` | Starts the configuration and LazyVim bootstrap. |
| `lua/config/lazy.lua` | Bootstraps and configures `lazy.nvim` and LazyVim imports. |
| `lua/config/options.lua` | Local Neovim options. |
| `lua/config/keymaps.lua` | Local key mappings. |
| `lua/config/autocmds.lua` | Local autocommands. |
| `lua/plugins/` | Plugin specifications loaded automatically by `lazy.nvim`. |
| `lua/plugins/nix.lua` | Enables `nixd` for Nix files and disables the alternative `nil_ls` server. |
| `lua/plugins/ui.lua` | UI overrides; currently disables `bufferline.nvim`. |
| `lua/plugins/example.lua` | Disabled reference examples. It has no effect unless its early return is removed. |
| `stylua.toml` | Lua formatting rules. |

## Making changes

Add a plugin specification in `lua/plugins/`, or change the appropriate file
under `lua/config/`. Format Lua changes with:

```bash
stylua nvim
```

Restart Neovim to load configuration changes. Plugin installation and updates
are managed by `lazy.nvim`; its state and lockfile are intentionally stored in
Neovim's state directory, outside this repository.

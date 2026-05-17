# LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## Adding your own plugins and config

### Plugins

Add plugin specs in `lua/plugins/`. Every `.lua` file in this directory is auto-loaded by LazyVim.

- New file: Create `lua/plugins/myplugins.lua` (or any name) and return a table of plugin specs.
- Example: `lua/plugins/example.lua` shows patterns. It returns early by default; remove the guard line to use it.

### Configuration

| File | Purpose |
|------|---------|
| `lua/config/options.lua` | Neovim options (`vim.opt`) |
| `lua/config/keymaps.lua` | Keymaps |
| `lua/config/autocmds.lua` | Autocommands |

Edit these files directly. Changes apply after restarting Neovim or running `:source $MYVIMRC`.

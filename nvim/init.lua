vim.g.lazyvim_json = vim.fn.stdpath("state") .. "/lazyvim.json"

-- Optional machine-local additions live outside the Nix-managed configuration.
-- For example: ~/.config/nvim-local/lua/plugins/my-local-plugin.lua
local local_config = vim.fn.stdpath("config") .. "-local"
local uv = vim.uv or vim.loop
if uv and uv.fs_stat(local_config) then
  vim.opt.rtp:append(local_config)
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.g.lazyvim_json = vim.fn.stdpath("state") .. "/lazyvim.json"

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

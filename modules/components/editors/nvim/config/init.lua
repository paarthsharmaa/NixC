vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.keymaps")
require("config.project").setup()
-- Load before lazy.nvim: lazy resets the runtimepath to plugins only, so
-- modules from this (Nix store) config dir can't be found from plugin
-- callbacks afterwards. Loaded modules stay cached in package.loaded.
require("config.matugen")
require("config.lazy")

require("options")
require("autocommands")

-- LAZY
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end
---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- PLUGINS
require("lazy").setup({
	require("plugins/treesitter"),
	require("plugins/mason"),
	require("plugins/mini"),
	require("plugins/snacks"),
	require("plugins/persistence"),
	require("plugins/whichkey"),
	require("plugins/flash"),
	require("plugins/themes"),
	require("plugins/neotree"),
	require("plugins/telescope"),
	require("plugins/conform"),
	require("plugins/blink"),
	require("plugins/lsp"),
	require("plugins/trouble"),
	require("plugins/noice"),
	require("plugins/lualine"),
	require("plugins/treesj"),
})

-- KEYMAPS
require("keymaps.misc")
require("keymaps.git")
require("keymaps.lsp")
require("keymaps.neotree")
require("keymaps.telescope")
require("keymaps.treesj")

-- SCHEME
vim.cmd("colorscheme kanagawa-wave")

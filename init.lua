require("options")
require("autocommands")

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
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
	require("plugins/whichkey"),
	require("plugins/flash"),
	require("plugins/themes"),
	require("plugins/neotree"),
	require("plugins/telescope"),
	require("plugins/conform"),
	require("plugins/blink"),
	require("plugins/lsp"),
})

vim.cmd("colorscheme kanagawa-wave")
require("keymaps")

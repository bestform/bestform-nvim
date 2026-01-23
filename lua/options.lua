vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

vim.o.number = true

vim.o.mouse = "a"

-- enable this if we see the mode in the status line
-- vim.o.showmode = false

vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- TODO: understand what this is doing
vim.o.breakindent = true

vim.o.undofile = true

-- for better search
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.signcolumn = "yes"

-- TODO: find out what exactly those do. They sound good in kickstart but I want to understand them
vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.o.splitright = true
vim.o.splitbelow = true

-- for preview of substitutions
vim.o.inccommand = "split"

vim.o.cursorline = true

vim.o.scrolloff = 10

-- show dialog instead of failing when quitting without saving
vim.o.confirm = true

-- indentation
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

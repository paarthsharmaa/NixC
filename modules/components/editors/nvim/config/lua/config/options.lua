local opt = vim.opt

-- Interface
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.cursorline = true
opt.showmode = false

-- Editing
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true

-- Searching
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- Windows
opt.splitbelow = true
opt.splitright = true

-- Responsiveness
opt.updatetime = 250
opt.timeoutlen = 400

-- Persistent undo
opt.undofile = true

-- Avoid swap files for normal editing.
opt.swapfile = false

-- Use the Wayland system clipboard.
opt.clipboard = "unnamedplus"

-- Keep context while scrolling.
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Better completion menu behavior.
opt.completeopt = {
	"menu",
	"menuone",
	"noselect",
}

-- Highlight the current matching bracket.
opt.showmatch = true

local map = vim.keymap.set

local function opts(description)
	return {
		noremap = true,
		silent = true,
		desc = description,
	}
end

-- Files
map("n", "<leader>w", "<cmd>write<cr>", opts("Save file"))
map("n", "<leader>q", "<cmd>quit<cr>", opts("Quit window"))
map("n", "<leader>Q", "<cmd>quitall<cr>", opts("Quit Neovim"))

-- Search highlighting
map("n", "<leader>h", "<cmd>nohlsearch<cr>", opts("Clear search highlighting"))

-- Window navigation
map("n", "<C-h>", "<C-w>h", opts("Move to left window"))
map("n", "<C-j>", "<C-w>j", opts("Move to lower window"))
map("n", "<C-k>", "<C-w>k", opts("Move to upper window"))
map("n", "<C-l>", "<C-w>l", opts("Move to right window"))

-- Resize windows
map("n", "<C-Up>", "<cmd>resize +2<cr>", opts("Increase window height"))

map("n", "<C-Down>", "<cmd>resize -2<cr>", opts("Decrease window height"))

map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", opts("Decrease window width"))

map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", opts("Increase window width"))

-- Keep selected text selected while indenting.
map("v", "<", "<gv", opts("Indent left"))
map("v", ">", ">gv", opts("Indent right"))

-- Move selected lines.
map("v", "J", ":move '>+1<cr>gv=gv", opts("Move selection down"))

map("v", "K", ":move '<-2<cr>gv=gv", opts("Move selection up"))

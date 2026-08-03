local uv = vim.uv or vim.loop

local data_dir = vim.fn.stdpath("data")
local state_dir = vim.fn.stdpath("state")

local lazy_path = data_dir .. "/lazy/lazy.nvim"
local lockfile = state_dir .. "/lazy-lock.json"

vim.fn.mkdir(state_dir, "p")

-- Find the repository-provided lockfile relative to this Lua file.
local current_file = debug.getinfo(1, "S").source:sub(2)

local config_root = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(current_file)))

local seed_lockfile = config_root .. "/lazy-lock.json"

-- On a fresh machine, seed the writable lockfile from the repository.
if vim.fn.filereadable(lockfile) == 0 and vim.fn.filereadable(seed_lockfile) == 1 then
	vim.fn.writefile(vim.fn.readfile(seed_lockfile), lockfile)
end

-- Install lazy.nvim on the first launch.
if not uv.fs_stat(lazy_path) then
	local output = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazy_path,
	})

	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{
				"Failed to clone lazy.nvim:\n",
				"ErrorMsg",
			},
			{
				output,
				"WarningMsg",
			},
			{
				"\nPress any key to exit.",
				"Normal",
			},
		}, true, {})

		vim.fn.getchar()
		os.exit(1)
	end
end

vim.opt.rtp:prepend(lazy_path)

require("lazy").setup({
	spec = {
		{
			import = "plugins",
		},
	},

	-- The Nix-store configuration is read-only, so use XDG state.
	lockfile = lockfile,

	defaults = {
		lazy = false,
		version = false,
	},

	install = {
		colorscheme = {
			"catppuccin",
			"habamax",
		},
	},

	checker = {
		enabled = false,
	},

	change_detection = {
		enabled = true,
		notify = false,
	},

	ui = {
		border = "rounded",
	},
})

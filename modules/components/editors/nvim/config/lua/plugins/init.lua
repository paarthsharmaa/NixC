return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,

		config = function()
			require("catppuccin").setup({
				flavour = "mocha",

				integrations = {
					gitsigns = true,
					telescope = true,
					which_key = true,
				},
			})

			vim.cmd.colorscheme("catppuccin")
		end,
	},

	{
		"nvim-lua/plenary.nvim",
		lazy = true,
	},

	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
	},

	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",

		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},

		opts = {
			options = {
				theme = "auto",
				globalstatus = true,
				section_separators = "",
				component_separators = "",
			},
		},
	},

	{
		"lewis6991/gitsigns.nvim",
		event = {
			"BufReadPre",
			"BufNewFile",
		},

		opts = {},
	},

	{
		"folke/which-key.nvim",
		event = "VeryLazy",

		opts = {
			delay = 300,
		},
	},

	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",

		dependencies = {
			"nvim-lua/plenary.nvim",
		},

		keys = {
			{
				"<leader>ff",
				"<cmd>Telescope find_files<cr>",
				desc = "Find files",
			},
			{
				"<leader>fg",
				"<cmd>Telescope live_grep<cr>",
				desc = "Search text",
			},
			{
				"<leader>fb",
				"<cmd>Telescope buffers<cr>",
				desc = "Open buffers",
			},
			{
				"<leader>fh",
				"<cmd>Telescope help_tags<cr>",
				desc = "Help tags",
			},
		},

		opts = {
			defaults = {
				border = true,
			},
		},
	},
}

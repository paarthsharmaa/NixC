return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,

		config = function()
			require("catppuccin").setup({
				flavour = "mocha",

        transparent_background = true,

        float = {
            transparent = true,
            solid = false,
        },

				integrations = {
					gitsigns = true,
					snacks = true,
					which_key = true,
				},
			})

			vim.cmd.colorscheme("catppuccin")
		end,
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
}

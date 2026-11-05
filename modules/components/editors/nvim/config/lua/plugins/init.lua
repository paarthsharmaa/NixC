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
		end,
	},

	-- Colors follow the wallpaper (matugen); catppuccin above is the fallback.
	{
		"nvim-mini/mini.base16",
		version = false,
		lazy = false,
		priority = 999,

		dependencies = {
			"catppuccin",
		},

		config = function()
			require("config.matugen").load()
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

		-- A function, so the theme is built from the matugen colors at load time.
		opts = function()
			return {
				options = {
					theme = require("config.matugen").lualine_theme(),
				globalstatus = true,
					section_separators = "",
					component_separators = "",
				},
			}
		end,
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
			win = { border = "rounded" },
		},
	},
}

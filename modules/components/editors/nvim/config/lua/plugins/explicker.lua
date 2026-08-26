return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,

		opts = {
			picker = {
				enabled = true,
			},

			explorer = {
				enabled = true,
				replace_netrw = true,
				trash = true,
			},
		},

		keys = {
			-- Picker
      {
        "<leader>fs",
        function()
          Snacks.picker.smart()
        end,
        desc = "Smart find",
      },
			{
				"<leader>ff",
				function()
					Snacks.picker.files()
				end,
				desc = "Find files",
			},
			{
				"<leader>fg",
				function()
					Snacks.picker.grep()
				end,
				desc = "Search text",
			},
			{
				"<leader>fb",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Open buffers",
			},
			{
				"<leader>fh",
				function()
					Snacks.picker.help()
				end,
				desc = "Help tags",
			},

			-- Explorer
			{
				"<leader>e",
				function()
					Snacks.explorer()
				end,
				desc = "File explorer",
			},
		},
	},
}

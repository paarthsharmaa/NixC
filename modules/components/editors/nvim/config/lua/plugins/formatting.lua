return {
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local conform = require("conform")
			local function first_available(names)
				return function(bufnr)
					for _, name in ipairs(names) do
						if conform.get_formatter_info(name, bufnr).available then
							return { name }
						end
					end
					return {}
				end
			end
			local prettier = first_available({ "prettierd", "prettier" })
			conform.setup({
				formatters_by_ft = {
					python = first_available({ "ruff_format", "black" }),
					rust = first_available({ "rustfmt" }),
					javascript = prettier,
					javascriptreact = prettier,
					typescript = prettier,
					typescriptreact = prettier,
					html = prettier,
					css = prettier,
					json = prettier,
					nix = first_available({ "alejandra", "nixfmt" }),
					qml = first_available({ "qmlformat" }),
					lua = first_available({ "stylua" }),
				},
				default_format_opts = { lsp_format = "never" },
				notify_no_formatters = false,
			})
			vim.keymap.set({ "n", "v" }, "<leader>cf", function()
				if #conform.list_formatters_to_run(0) == 0 then
					vim.notify("No formatter available; add one to this project's devenv.nix", vim.log.levels.INFO)
					return
				end
				conform.format({ async = true })
			end, { desc = "Format buffer or selection" })
		end,
	},
}

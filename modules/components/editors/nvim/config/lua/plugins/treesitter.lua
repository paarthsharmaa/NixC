return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		config = function()
			local treesitter = require("nvim-treesitter")
			treesitter.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })
			vim.treesitter.language.register("qmljs", { "qml", "qmljs" })
			local parsers = {
				"python",
				"rust",
				"javascript",
				"typescript",
				"tsx",
				"html",
				"css",
				"nix",
				"qmljs",
				"lua",
				"vim",
				"vimdoc",
				"query",
				"json",
			}
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("ProjectTreesitter", { clear = true }),
				callback = function(event)
					-- Missing parsers leave normal syntax highlighting in place.
					pcall(vim.treesitter.start, event.buf)
				end,
			})
			vim.api.nvim_create_user_command("TSInstallProject", function()
				local available = require("config.project").available
				local missing = {}
				for _, command in ipairs({ "tree-sitter", "curl", "tar" }) do
					if not available(command) then
						missing[#missing + 1] = command
					end
				end
				if not (available("cc") or available("gcc") or available("clang")) then
					missing[#missing + 1] = "a C compiler"
				end
				if #missing > 0 then
					vim.notify("Enter a devenv shell providing " .. table.concat(missing, ", "), vim.log.levels.WARN)
					return
				end
				treesitter.install(parsers)
			end, { desc = "Install configured parsers using tools from devenv" })
		end,
	},
}

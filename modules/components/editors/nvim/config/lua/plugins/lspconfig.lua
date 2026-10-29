return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			local project = require("config.project")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local servers = {
				pyright = {},
				ruff = {},
				rust_analyzer = {},
				-- Resolve these from PATH, like the other project-provided servers.
				ts_ls = { cmd = { "typescript-language-server", "--stdio" } },
				html = { cmd = { "vscode-html-language-server", "--stdio" } },
				cssls = { cmd = { "vscode-css-language-server", "--stdio" } },
				eslint = { cmd = { "vscode-eslint-language-server", "--stdio" } },
				qmlls = { cmd = { "qmlls", "-E" } },
				lua_ls = {
					settings = {
						Lua = {
							diagnostics = { globals = { "vim", "Snacks" } },
							workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
						},
					},
				},
				nixd = { settings = { nixd = project.nixd_settings() } },
				devenv = {
					cmd = function(dispatchers, config)
						return vim.lsp.rpc.start({ "devenv", "lsp" }, dispatchers, { cwd = config.root_dir })
					end,
					filetypes = { "nix" },
				},
			}

			-- Let Pyright use the interpreter activated by uv/devenv.
			local python = vim.fn.exepath("python")
			if python ~= "" then
				servers.pyright.settings = { python = { pythonPath = python } }
			end

			for name, overrides in pairs(servers) do
				local server_name = name
				local upstream = vim.lsp.config[server_name] or {}
				local command = overrides.cmd or upstream.cmd
				local executable = server_name == "devenv" and "devenv" or command[1]
				local original_root = upstream.root_dir
				local markers = upstream.root_markers or { "devenv.nix", ".git" }

				overrides.capabilities = capabilities
				overrides.root_dir = function(bufnr, on_dir)
					-- Configuration alone does not install a server. Check each buffer.
					if not project.available(executable) then
						return
					end
					if server_name == "rust_analyzer" and not project.available("cargo") then
						return
					end
					local filename = vim.api.nvim_buf_get_name(bufnr)
					local is_devenv = vim.tbl_contains({ "devenv.nix", "devenv.local.nix" }, vim.fs.basename(filename))
					if server_name == "devenv" then
						if is_devenv then
							on_dir(vim.fs.dirname(filename))
						end
						return
					elseif server_name == "nixd" and is_devenv and project.available("devenv") then
						return -- devenv supplies its own nixd settings; avoid two clients.
					end
					if original_root then
						original_root(bufnr, on_dir)
					else
						on_dir(vim.fs.root(bufnr, markers) or vim.fs.dirname(filename))
					end
				end
				vim.lsp.config(server_name, overrides)
				vim.lsp.enable(server_name)
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("ProjectLsp", { clear = true }),
				callback = function(event)
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.name == "ruff" then
						client.server_capabilities.hoverProvider = false -- Pyright owns Python hover.
					end
					local function map(keys, action, description)
						vim.keymap.set("n", keys, action, { buffer = event.buf, desc = description })
					end
					map("gd", vim.lsp.buf.definition, "Go to definition")
					map("gr", vim.lsp.buf.references, "References")
					map("K", vim.lsp.buf.hover, "Hover documentation")
					map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
					map("<leader>ca", vim.lsp.buf.code_action, "Code actions")
				end,
			})
		end,
	},
}

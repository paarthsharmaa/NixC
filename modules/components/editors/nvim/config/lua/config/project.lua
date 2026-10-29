local M = {}

-- Use the launch environment. Never install tools or activate another project here.
function M.available(command)
	return vim.fn.executable(command) == 1
end

function M.nixd_settings()
	local settings = {}
	local filename = vim.env.NVIM_NIXD_SETTINGS_FILE
	if filename and filename ~= "" then
		local ok, decoded = pcall(function()
			return vim.json.decode(table.concat(vim.fn.readfile(filename), "\n"))
		end)
		if ok and type(decoded) == "table" and not vim.islist(decoded) then
			settings = decoded
		else
			vim.schedule(function()
				vim.notify("Ignoring invalid NVIM_NIXD_SETTINGS_FILE; expected a JSON object", vim.log.levels.WARN)
			end)
		end
	end
	-- Opt in from a NixOS project's devenv.nix; select the current host at runtime.
	local nixos_flake = vim.env.NVIM_NIXD_NIXOS_FLAKE
	if nixos_flake and nixos_flake ~= "" then
		local function nix_string(value)
			return vim.json.encode(value):gsub("%${", "\\${")
		end
		settings = vim.tbl_deep_extend("force", settings, {
			options = {
				nixos = {
					expr = "(builtins.getFlake "
						.. nix_string("path:" .. nixos_flake)
						.. ").nixosConfigurations."
						.. nix_string(vim.uv.os_gethostname())
						.. ".options",
				},
			},
		})
	end
	return settings
end

function M.setup()
	vim.filetype.add({ extension = { qml = "qml" } })
	vim.api.nvim_create_user_command("ProjectTools", function()
		local commands = {
			"devenv",
			"nixd",
			"alejandra",
			"nixfmt",
			"lua-language-server",
			"stylua",
			"python",
			"pyright-langserver",
			"ruff",
			"rust-analyzer",
			"rustfmt",
			"cargo",
			"typescript-language-server",
			"vscode-html-language-server",
			"vscode-css-language-server",
			"vscode-eslint-language-server",
			"prettierd",
			"prettier",
			"qmlls",
			"qmlformat",
			"tree-sitter",
			"cc",
			"curl",
			"tar",
		}
		local lines = { "devenv root: " .. (vim.env.DEVENV_ROOT or "not active"), "" }
		for _, command in ipairs(commands) do
			local executable = vim.fn.exepath(command)
			lines[#lines + 1] = command .. ": " .. (executable ~= "" and executable or "unavailable (skipped)")
		end
		vim.api.nvim_echo({ { table.concat(lines, "\n") } }, true, {})
	end, { desc = "Show tools visible in this Neovim process" })
end

return M

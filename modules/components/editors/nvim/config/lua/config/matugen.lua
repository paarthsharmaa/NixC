-- Wallpaper colors from matugen.
--
-- theme-apply renders ~/.cache/matugen/nvim-colors.lua (a base16 palette) and
-- calls _G.MatugenReload() in every running Neovim. Without that file (no
-- theme applied yet) we fall back to catppuccin.

local M = {}

local cache = vim.env.XDG_CACHE_HOME or (vim.env.HOME .. "/.cache")
local path = cache .. "/matugen/nvim-colors.lua"

-- Groups whose background is cleared so kitty's translucency shows through.
-- Floats and side panels (snacks explorer/picker link to NormalFloat) are
-- included, otherwise they show up as solid blocks inside a see-through editor.
local transparent = {
	"Normal",
	"NormalNC",
	"NormalFloat",
	"FloatBorder",
	"FloatTitle",
	"SignColumn",
	"EndOfBuffer",
	"LineNr",
	"CursorLineNr",
	"LineNrAbove",
	"LineNrBelow",
	"FoldColumn",
	"WinSeparator",
	"VertSplit",
	"TabLineFill",
	"WinBar",
	"WinBarNC",
	-- Statusline text without its own background (lualine's middle section)
	-- is filled with StatusLine's, so that one must be clear too.
	"StatusLine",
	"StatusLineNC",
	-- A solid bar across a see-through window looks out of place; the
	-- current line is marked by its number/text color instead (below).
	"CursorLine",
	"CursorLineSign",
	"CursorLineFold",
}

-- lualine theme from the same palette: a colored mode block per mode, the
-- rest see-through like the editor. (lualine's "auto" theme guesses from the
-- StatusLine highlight, which is cleared above, and ends up black.)
function M.lualine_theme()
	local c = M.colors
	if not c then
		return "auto"
	end
	local function mode(color)
		return {
			a = { fg = c.base00, bg = color, gui = "bold" },
			b = { fg = color, bg = "NONE" },
			c = { fg = c.base04, bg = "NONE" },
		}
	end
	return {
		normal = mode(c.base0D),
		insert = mode(c.base0B),
		visual = mode(c.base0E),
		replace = mode(c.base08),
		command = mode(c.base0A),
		terminal = mode(c.base0C),
		inactive = {
			a = { fg = c.base04, bg = "NONE" },
			b = { fg = c.base04, bg = "NONE" },
			c = { fg = c.base04, bg = "NONE" },
		},
	}
end

-- Groups that keep their background: selections and search matches need a
-- real highlight to be visible.
local keep_bg = {
	Visual = true,
	VisualNOS = true,
	Search = true,
	IncSearch = true,
	CurSearch = true,
	Substitute = true,
	PmenuSel = true,
	PmenuThumb = true,
	WildMenu = true,
	QuickFixLine = true,
	TermCursor = true,
}

-- Clear every highlight whose background is one of the editor surfaces
-- (base00/base01), whatever plugin defined it: git signs, diff lines,
-- popups, which-key, completion... It also runs whenever lazy.nvim loads
-- a plugin, so plugins that aren't loaded yet are covered when they are.
function M.clear_surfaces()
	local c = M.colors
	if not c then
		return
	end
	local surfaces = {
		[tonumber(c.base00:sub(2), 16)] = true,
		[tonumber(c.base01:sub(2), 16)] = true,
	}
	for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
		if not hl.link and hl.bg and surfaces[hl.bg] and not keep_bg[name] then
			hl.bg = nil
			hl.ctermbg = nil
			vim.api.nvim_set_hl(0, name, hl)
		end
	end
end

vim.api.nvim_create_autocmd("User", {
	pattern = "LazyLoad",
	callback = function()
		vim.schedule(M.clear_surfaces)
	end,
})

function M.load()
	local ok, palette = pcall(dofile, path)

	if not ok or type(palette) ~= "table" then
		vim.cmd.colorscheme("catppuccin")
		return
	end

	vim.o.background = palette.mode == "light" and "light" or "dark"

	local colors = {}
	for key, value in pairs(palette) do
		if key:match("^base0") then
			colors[key] = value
		end
	end

	M.colors = colors
	require("mini.base16").setup({ palette = colors, use_cterm = true })
	vim.g.colors_name = "matugen"

	for _, group in ipairs(transparent) do
		local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
		hl.bg = nil
		vim.api.nvim_set_hl(0, group, hl)
	end

	-- Current line: accent-colored bold line number; in the explorer and
	-- pickers, the selected entry turns accent-colored and bold.
	vim.api.nvim_set_hl(0, "CursorLineNr", { fg = colors.base0D, bold = true })
	vim.api.nvim_set_hl(0, "SnacksPickerListCursorLine", { fg = colors.base0D, bold = true })
	vim.api.nvim_set_hl(0, "SnacksPickerCursorLine", { fg = colors.base0D, bold = true })

	M.clear_surfaces()

	-- Let plugins re-read the new colors.
	vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "matugen" })

	-- lualine's theme is a table built from the colors, so rebuild it.
	if package.loaded["lualine"] then
		local lualine = require("lualine")
		local config = lualine.get_config()
		config.options.theme = M.lualine_theme()
		lualine.setup(config)
	end
end

_G.MatugenReload = M.load

return M

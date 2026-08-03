-- Minimal Hyprland Lua configuration.
-- Expand this incrementally while learning.

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})

local mainMod = "SUPER"

local terminal = "kitty"
local browser = "librewolf"
local editor = "codium"

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 10,
		border_size = 2,
		layout = "dwindle",

		col = {
			active_border = "rgba(89b4faff)",
			inactive_border = "rgba(585b70ff)",
		},
	},

	decoration = {
		rounding = 8,

		blur = {
			enabled = true,
			size = 4,
			passes = 1,
		},
	},

	animations = {
		enabled = true,
	},

	input = {
		kb_layout = "us",
		follow_mouse = 1,

		touchpad = {
			natural_scroll = true,
		},
	},

	dwindle = {
		preserve_split = true,
	},

	misc = {
		disable_hyprland_logo = false,
		force_default_wallpaper = -1,
	},
})

-- Use uwsm app for long-running graphical applications.
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("uwsm app -- " .. terminal))

hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("uwsm app -- " .. browser))

hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("uwsm app -- " .. editor))

hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("fuzzel --launch-prefix='uwsm app --'"))

hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))

hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("hyprctl dispatch exit"))

-- Focus movement.
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))

hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))

hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

-- Workspaces 1–10.
for workspace = 1, 10 do
	local key = workspace % 10

	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))

	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

-- Laptop media keys.
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)

hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })

hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

-- Enable after ChillPill has been tested:
--
-- hl.bind(
--     mainMod .. " + CTRL + C",
--     hl.dsp.exec_cmd(
--         "chillpill-ctl call controlCenter toggle"
--     )
-- )
--
-- hl.bind(
--     mainMod .. " + CTRL + V",
--     hl.dsp.exec_cmd(
--         "chillpill-ctl call cliphist toggle"
--     )
-- )
--
-- hl.bind(
--     mainMod .. " + CTRL + B",
--     hl.dsp.exec_cmd(
--         "chillpill-ctl call miniDashboard toggle"
--     )
-- )
--
-- hl.bind(
--     mainMod .. " + D",
--     hl.dsp.exec_cmd(
--         "chillpill-ctl call appLauncher toggle"
--     )
-- )

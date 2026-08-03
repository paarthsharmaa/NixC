-- Paarth's Hyprland configuration.
-- Start small and split it into modules later.

----------------
-- MONITOR
----------------

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})

----------------
-- PROGRAMS
----------------

local mainMod = "SUPER"
local terminal = "kitty"
local launcher = "fuzzel --launch-prefix='uwsm app --'"

----------------
-- APPEARANCE
----------------

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
			tap_to_click = true,
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

----------------
-- KEYBINDS
----------------

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("uwsm app -- " .. terminal))

hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(launcher))

hl.bind(mainMod .. " + C", hl.dsp.window.close())

hl.bind(
	mainMod .. " + V",
	hl.dsp.window.float({
		action = "toggle",
	})
)

hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("hyprctl dispatch exit"))

-- Focus movement.

hl.bind(
	mainMod .. " + H",
	hl.dsp.focus({
		direction = "left",
	})
)

hl.bind(
	mainMod .. " + J",
	hl.dsp.focus({
		direction = "down",
	})
)

hl.bind(
	mainMod .. " + K",
	hl.dsp.focus({
		direction = "up",
	})
)

hl.bind(
	mainMod .. " + L",
	hl.dsp.focus({
		direction = "right",
	})
)

-- Workspaces 1–10.

for workspace = 1, 10 do
	local key = workspace % 10

	hl.bind(
		mainMod .. " + " .. key,
		hl.dsp.focus({
			workspace = workspace,
		})
	)

	hl.bind(
		mainMod .. " + SHIFT + " .. key,
		hl.dsp.window.move({
			workspace = workspace,
		})
	)
end

----------------
-- LAPTOP KEYS
----------------

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), {
	locked = true,
	repeating = true,
})

hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), {
	locked = true,
	repeating = true,
})

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), {
	locked = true,
})

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), {
	locked = true,
	repeating = true,
})

hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), {
	locked = true,
	repeating = true,
})

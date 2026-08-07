local programs =
    require("common.programs")

local mod = "SUPER"

local function exec(command)
    return hl.dsp.exec_cmd(command)
end

-- Applications and shell UI.

hl.bind(
    mod .. " + RETURN",
    exec(programs.terminal),
    { description = "Open terminal" }
)

hl.bind(
    mod .. " + SPACE",
    exec(programs.launcher),
    { description = "Open application launcher" }
)

hl.bind(
    mod .. " + E",
    exec(programs.files),
    { description = "Open file manager" }
)

hl.bind(
    mod .. " + B",
    exec(programs.browser),
    { description = "Open browser" }
)

hl.bind(
    mod .. " + C",
    exec(programs.controlCenter),
    { description = "Open control center" }
)

hl.bind(
    mod .. " + W",
    exec(programs.wallpaper),
    { description = "Open wallpaper selector" }
)

hl.bind(
    mod .. " + M",
    exec(programs.media),
    { description = "Open media panel" }
)

hl.bind(
    mod .. " + N",
    exec(programs.notifications),
    { description = "Open notification center" }
)

hl.bind(
    mod .. " + SHIFT + V",
    exec(programs.clipboard),
    { description = "Open clipboard history" }
)

hl.bind(
    "Print",
    exec(programs.screenshot),
    { description = "Capture screen region" }
)

-- Session operations.

hl.bind(
    mod .. " + Q",
    hl.dsp.window.close(),
    { description = "Close active window" }
)

hl.bind(
    mod .. " + V",
    hl.dsp.window.float({
        action = "toggle",
    }),
    { description = "Toggle floating" }
)

hl.bind(
    mod .. " + SHIFT + L",
    exec(programs.lock),
    { description = "Lock session" }
)

hl.bind(
    mod .. " + SHIFT + E",
    exec(programs.logout),
    { description = "End graphical session" }
)

-- Focus movement.

local directions = {
    H = "left",
    J = "down",
    K = "up",
    L = "right",
}

for key, direction in pairs(directions) do
    hl.bind(
        mod .. " + " .. key,
        hl.dsp.focus({
            direction = direction,
        })
    )
end

-- Workspaces 1 through 10.

for workspace = 1, 10 do
    local key =
        workspace % 10

    hl.bind(
        mod .. " + " .. key,
        hl.dsp.focus({
            workspace = workspace,
        })
    )

    hl.bind(
        mod .. " + SHIFT + " .. key,
        hl.dsp.window.move({
            workspace = workspace,
        })
    )
end

-- Mouse movement and resizing.

hl.bind(
    mod .. " + mouse:272",
    hl.dsp.window.drag(),
    { mouse = true }
)

hl.bind(
    mod .. " + mouse:273",
    hl.dsp.window.resize(),
    { mouse = true }
)

-- Hardware controls.
--
-- Hyprland performs the real system action directly.
-- Quickshell IPC is best-effort and only displays UI.
--
-- This means volume, brightness and media controls
-- continue working even when Quickshell is not running.

hl.bind(
    "XF86AudioRaiseVolume",
    exec(
        "wpctl set-volume -l 1.0 "
        .. "@DEFAULT_AUDIO_SINK@ 5%+; "
        .. "qs ipc call island volumeOsd "
        .. ">/dev/null 2>&1 || true"
    ),
    {
        locked = true,
        repeating = true,
    }
)

hl.bind(
    "XF86AudioLowerVolume",
    exec(
        "wpctl set-volume "
        .. "@DEFAULT_AUDIO_SINK@ 5%-; "
        .. "qs ipc call island volumeOsd "
        .. ">/dev/null 2>&1 || true"
    ),
    {
        locked = true,
        repeating = true,
    }
)

hl.bind(
    "XF86AudioMute",
    exec(
        "wpctl set-mute "
        .. "@DEFAULT_AUDIO_SINK@ toggle; "
        .. "qs ipc call island volumeOsd "
        .. ">/dev/null 2>&1 || true"
    ),
    {
        locked = true,
    }
)

hl.bind(
    "XF86AudioMicMute",
    exec(
        "wpctl set-mute "
        .. "@DEFAULT_AUDIO_SOURCE@ toggle"
    ),
    {
        locked = true,
    }
)

hl.bind(
    "XF86MonBrightnessUp",
    exec(
        "brightnessctl set +5%; "
        .. "qs ipc call island brightnessOsd "
        .. ">/dev/null 2>&1 || true"
    ),
    {
        locked = true,
        repeating = true,
    }
)

hl.bind(
    "XF86MonBrightnessDown",
    exec(
        "brightnessctl set 5%-; "
        .. "qs ipc call island brightnessOsd "
        .. ">/dev/null 2>&1 || true"
    ),
    {
        locked = true,
        repeating = true,
    }
)

hl.bind(
    "XF86AudioPlay",
    exec("playerctl play-pause"),
    {
        locked = true,
    }
)

hl.bind(
    "XF86AudioNext",
    exec("playerctl next"),
    {
        locked = true,
    }
)

hl.bind(
    "XF86AudioPrev",
    exec("playerctl previous"),
    {
        locked = true,
    }
)

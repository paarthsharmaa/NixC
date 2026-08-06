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

-- Quickshell-backed hardware keys.
-- These update the value and display Shell Island's OSD.

hl.bind(
    "XF86AudioRaiseVolume",
    exec("qs ipc call island volUp"),
    {
        locked = true,
        repeating = true,
    }
)

hl.bind(
    "XF86AudioLowerVolume",
    exec("qs ipc call island volDown"),
    {
        locked = true,
        repeating = true,
    }
)

hl.bind(
    "XF86MonBrightnessUp",
    exec("qs ipc call island briUp"),
    {
        locked = true,
        repeating = true,
    }
)

hl.bind(
    "XF86MonBrightnessDown",
    exec("qs ipc call island briDown"),
    {
        locked = true,
        repeating = true,
    }
)

hl.bind(
    "XF86AudioPlay",
    exec("qs ipc call island mediaToggle"),
    { locked = true }
)

hl.bind(
    "XF86AudioNext",
    exec("qs ipc call island mediaNext"),
    { locked = true }
)

hl.bind(
    "XF86AudioPrev",
    exec("qs ipc call island mediaPrev"),
    { locked = true }
)

-- Mute currently remains direct because Shell Island
-- does not yet expose volMute or micMute IPC handlers.

hl.bind(
    "XF86AudioMute",
    exec(
        "wpctl set-mute "
        .. "@DEFAULT_AUDIO_SINK@ toggle"
    ),
    { locked = true }
)

hl.bind(
    "XF86AudioMicMute",
    exec(
        "wpctl set-mute "
        .. "@DEFAULT_AUDIO_SOURCE@ toggle"
    ),
    { locked = true }
)

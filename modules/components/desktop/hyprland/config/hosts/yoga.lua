-- Yoga 6 13ALC6 internal panel.
--
-- Start at integer scale 1 for predictable application
-- rendering. Move to 1.25 only if the interface feels too small.

hl.monitor({
    output = "eDP-1",
    mode = "1920x1080@60",
    position = "0x0",
    scale = 1,
})

-- Fallback for USB-C displays and unexpected connector names.

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

-- Yoga laptop efficiency adjustments.

hl.config({
    misc = {
        vfr = true,
    },

    decoration = {
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
        },
    },
})

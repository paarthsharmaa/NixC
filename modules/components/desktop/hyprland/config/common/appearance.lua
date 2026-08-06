hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,

        border_size = 2,
        resize_on_border = true,
        allow_tearing = false,

        layout = "dwindle",

        col = {
            active_border =
                "rgba(89b4faff)",

            inactive_border =
                "rgba(585b70aa)",
        },
    },

    decoration = {
        rounding = 10,
        rounding_power = 2,

        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a,
        },

        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.12,
        },
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        disable_hyprland_logo = true,
        force_default_wallpaper = 0,
    },
})

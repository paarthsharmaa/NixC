hl.window_rule({
    name =
        "suppress-maximize-events",

    match = {
        class = ".*",
    },

    suppress_event =
        "maximize",
})

hl.window_rule({
    name =
        "fix-xwayland-drag-focus",

    match = {
        class = "^$",
        title = "^$",

        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },

    no_focus = true,
})

-- Notification center drops down from the top edge.
hl.layer_rule({
    name =
        "notification-center-slide",

    match = {
        namespace = "^swaync-control-center$",
    },

    animation = "slide top",
})

-- Quickshell clipboard sheet rises from the bottom edge.
hl.layer_rule({
    name =
        "clipboard-slide",

    match = {
        namespace = "^quickshell:clipboard$",
    },

    animation = "slide bottom",
})

-- Legion 5 Pro internal 16:10 panel: verified with hyprctl monitors all.
-- Render at 1920x1200 for larger UI elements, keeping the 165 Hz refresh rate.
-- Match the panel description so this also works if DDG changes its connector.
hl.monitor({
    output = "desc:California Institute of Technology 0x1600",
    mode = "1920x1200@165.02",
    position = "0x0",
    scale = 1,
})

-- External displays retain their preferred mode.
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

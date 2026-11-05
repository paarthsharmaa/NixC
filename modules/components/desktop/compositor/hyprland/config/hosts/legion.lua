-- Legion 5 Pro internal 16:10 panel: verified with hyprctl monitors all.
-- Native 2560x1600 at 165 Hz, scaled 4/3 so the UI is laid out like
-- 1920x1200 but stays sharp. (In DDG mode the NVIDIA-driven panel only
-- offers 2560x1600, so a 1920x1200 mode fell back to native at scale 1.)
-- Match the panel description so this also works if DDG changes its connector.
hl.monitor({
    output = "desc:California Institute of Technology 0x1600",
    mode = "2560x1600@165.02",
    position = "0x0",
    scale = 1.333333,
})

-- External displays retain their preferred mode.
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

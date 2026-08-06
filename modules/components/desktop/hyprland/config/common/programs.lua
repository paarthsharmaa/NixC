return {
    terminal =
        "uwsm app -- kitty",

    browser =
        "uwsm app -- librewolf",

    files =
        "uwsm app -- dolphin",

    launcher =
        "qs ipc call island launcher",

    controlCenter =
        "qs ipc call island controlcenter",

    wallpaper =
        "qs ipc call island wallpaper",

    media =
        "qs ipc call island media",

    notifications =
        "swaync-client -t -sw",

    lock =
        "hyprlock",

    logout =
        "uwsm stop",

    screenshot =
        "screenshot-region",

    clipboard =
        "clipboard-picker",
}

return {
    terminal =
        "uwsm app -t service -- kitty",

    browser =
        "uwsm app -t service -- librewolf",

    files =
        "uwsm app -t service -- dolphin",

    launcher =
        "qs ipc call island launcher "
        .. ">/dev/null 2>&1 "
        .. "|| uwsm app -t service -- fuzzel",

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

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    FileView {
        id: colorsFile

        path:
            Quickshell.env("HOME")
            + "/.cache/iris/quickshell.json"

        watchChanges: true
        printErrors: false

        onFileChanged: this.reload()

        JsonAdapter {
            id: adapter

            property string background: "#1a1b26"
            property string foreground: "#c0caf5"

            property string surface: "#24283b"
            property string dim: "#565f89"
            property string accent: "#7aa2f7"

            property string color0: "#1a1b26"
            property string color1: "#f7768e"
            property string color2: "#9ece6a"
            property string color3: "#e0af68"
            property string color4: "#7aa2f7"
            property string color5: "#bb9af7"
            property string color6: "#7dcfff"
            property string color7: "#a9b1d6"
            property string color8: "#414868"
            property string color9: "#f7768e"
            property string color10: "#9ece6a"
            property string color11: "#e0af68"
            property string color12: "#7aa2f7"
            property string color13: "#bb9af7"
            property string color14: "#7dcfff"
            property string color15: "#c0caf5"
        }
    }

    readonly property string background:
        adapter.background

    readonly property string foreground:
        adapter.foreground

    readonly property string surface:
        adapter.surface

    readonly property string dim:
        adapter.dim

    readonly property string accent:
        adapter.accent

    readonly property string color0: adapter.color0
    readonly property string color1: adapter.color1
    readonly property string color2: adapter.color2
    readonly property string color3: adapter.color3
    readonly property string color4: adapter.color4
    readonly property string color5: adapter.color5
    readonly property string color6: adapter.color6
    readonly property string color7: adapter.color7
    readonly property string color8: adapter.color8
    readonly property string color9: adapter.color9
    readonly property string color10: adapter.color10
    readonly property string color11: adapter.color11
    readonly property string color12: adapter.color12
    readonly property string color13: adapter.color13
    readonly property string color14: adapter.color14
    readonly property string color15: adapter.color15

    readonly property string critical:
        adapter.color9
}

pragma Singleton

import QtQuick
import Quickshell.Io

Item {
    id: root

    property bool active: false
    property bool available: false

    function refresh(): void {
        if (!stateProc.running)
            stateProc.running = true
    }

    function toggle(): void {
        if (toggleProc.running)
            return

        toggleProc.command =
            root.active
                ? [
                    "hyprctl",
                    "hyprsunset",
                    "identity"
                  ]
                : [
                    "hyprctl",
                    "hyprsunset",
                    "temperature",
                    "4500"
                  ]

        toggleProc.running = true
    }

    Component.onCompleted:
        root.refresh()

    Process {
        id: stateProc

        command: [
            "hyprctl",
            "hyprsunset",
            "identity",
            "get"
        ]

        stdout: SplitParser {
            onRead: data => {
                const value =
                    data.trim()

                root.available =
                    value === "true"
                    || value === "false"

                root.active =
                    value === "false"
            }
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.available = false
                root.active = false
            }
        }
    }

    Process {
        id: toggleProc

        onExited:
            root.refresh()
    }
}

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string selectedPath: ""
    property string selectedMode: "dark"

    function apply(path: string, mode: string): void {
        selectedPath = path
        selectedMode = mode

        awwwProcess.exec([
            "awww",
            "img",
            path,

            "--transition-type",
            "grow",

            "--transition-pos",
            "0.5,0.5",

            "--transition-duration",
            "1.2",

            "--transition-fps",
            "60"
        ])
    }

    Process {
        id: awwwProcess

        onExited: function(exitCode, exitStatus) {
            if (exitCode !== 0)
                return

            const command = [
                "iris",
                root.selectedPath
            ]

            if (root.selectedMode === "dark")
                command.push("--dark", "1")
            else if (root.selectedMode === "light")
                command.push("--dark", "0")

            irisProcess.exec(command)
        }
    }

    Process {
        id: irisProcess

        onExited: function(exitCode, exitStatus) {
            if (exitCode !== 0)
                return

            const scheme =
                root.selectedMode === "dark"
                    ? "prefer-dark"
                    : "default"

            schemeProcess.exec([
                "gsettings",
                "set",
                "org.gnome.desktop.interface",
                "color-scheme",
                scheme
            ])

            swayncReload.exec([
                "swaync-client",
                "-rs"
            ])
        }
    }

    Process {
        id: schemeProcess
    }

    Process {
        id: swayncReload
    }
}

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

            themeProcess.exec([
                "theme-apply",
                root.selectedPath,
                root.selectedMode === "light" ? "light" : "dark"
            ])
        }
    }

    Process {
        id: themeProcess
    }
}

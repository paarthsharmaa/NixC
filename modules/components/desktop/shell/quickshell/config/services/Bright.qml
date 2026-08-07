pragma Singleton

import QtQuick
import Quickshell.Io

Item {
    id: root

    property int percent: 100
    property bool live: false

    property int _pendingPct: -1

    function refresh(): void {
        if (!poll.running)
            poll.running = true
    }

    function setPercent(value: int): void {
        const clamped =
            Math.max(
                5,
                Math.min(100, value)
            )

        root.percent = clamped
        root._pendingPct = clamped

        setTimer.restart()
    }

    onLiveChanged: {
        if (root.live)
            root.refresh()
    }

    Component.onCompleted:
        root.refresh()

    Timer {
        id: setTimer

        interval: 50

        onTriggered: {
            if (root._pendingPct < 0)
                return

            setProc.command = [
                "brightnessctl",
                "set",
                String(root._pendingPct) + "%"
            ]

            root._pendingPct = -1
            setProc.running = true
        }
    }

    Process {
        id: poll

        command: [
            "brightnessctl",
            "-m"
        ]

        stdout: SplitParser {
            onRead: data => {
                const parts =
                    data.trim().split(",")

                if (parts.length < 5)
                    return

                const value =
                    parseInt(parts[4])

                if (!isNaN(value))
                    root.percent = value
            }
        }
    }

    Process {
        id: setProc

        onExited:
            root.refresh()
    }
}

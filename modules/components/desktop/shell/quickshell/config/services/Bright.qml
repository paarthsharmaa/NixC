pragma Singleton

import QtQuick
import Quickshell.Io

Item {
    id: root

    property int percent: 100

    property int _pendingPercent: -1
    property bool _refreshPending: false

    function refresh(): void {
        if (poll.running) {
            root._refreshPending = true
            return
        }

        poll.running = true
    }

    function setPercent(value: int): void {
        const clamped =
            Math.max(
                5,
                Math.min(100, value)
            )

        // Immediate visual feedback.
        root.percent = clamped

        // Collapse rapid slider motion into the latest value.
        root._pendingPercent = clamped

        setTimer.restart()
    }

    function applyPending(): void {
        if (setProc.running)
            return

        if (root._pendingPercent < 0)
            return

        const value =
            root._pendingPercent

        root._pendingPercent = -1

        setProc.exec([
            "brightnessctl",
            "set",
            String(value) + "%"
        ])
    }

    Component.onCompleted:
        root.refresh()

    Timer {
        id: setTimer

        interval: 35
        repeat: false

        onTriggered:
            root.applyPending()
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

                // brightnessctl -m:
                //
                // device,class,current,percentage,max
                //
                // parseInt("67%") -> 67
                const value =
                    parseInt(parts[3])

                if (!isNaN(value))
                    root.percent =
                        Math.max(
                            0,
                            Math.min(100, value)
                        )
            }
        }

        onExited: {
            if (root._refreshPending) {
                root._refreshPending = false
                poll.running = true
            }
        }
    }

    Process {
        id: setProc

        onExited: {
            if (root._pendingPercent >= 0) {
                setTimer.restart()
                return
            }

            root.refresh()
        }
    }
}

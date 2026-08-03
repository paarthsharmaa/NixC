//@ pragma ShellId nixc

import Quickshell
import QtQuick

ShellRoot {
    id: root

    property string timeText:
        Qt.formatTime(new Date(), "hh:mm")

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            root.timeText =
                Qt.formatTime(new Date(), "hh:mm")
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 36
            exclusiveZone: implicitHeight

            color: "#1e1e2e"

            Text {
                anchors.centerIn: parent

                text: root.timeText
                color: "#cdd6f4"

                font {
                    pixelSize: 15
                    bold: true
                }
            }
        }
    }
}

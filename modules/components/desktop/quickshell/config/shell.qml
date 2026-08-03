import Quickshell
import QtQuick

PanelWindow {
    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 32
    color: "#1e1e2e"

    Text {
        anchors.centerIn: parent
        text: "Paarth's Quickshell development shell"
        color: "#cdd6f4"
    }
}

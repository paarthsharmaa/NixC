pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Hyprland
import "services"

// Workspace tracker: one capsule per workspace, plus a single highlight
// that slides to the active one (sliding instead of each dot popping is
// what makes it feel smooth).
//   empty    -> small, faint
//   occupied -> taller, brighter
//   active   -> the highlight capsule
// Click a slot to switch, scroll to step through them.
Item {
    id: root

    property color color: Colors.foreground
    property real slotWidth: 6
    property real spacing: 5
    property real activeWidth: 8
    property real activeHeight: 16

    readonly property int activeId: Hyprland.focusedWorkspace?.id ?? 1

    // Workspaces with windows, by id.
    readonly property var occupied: {
        const out = {}
        for (const ws of Hyprland.workspaces.values) {
            if (ws.id > 0 && (ws.toplevels?.values?.length ?? 0) > 0) out[ws.id] = true
        }
        return out
    }

    // At least Settings.workspaces slots; more when a higher one is in use.
    readonly property int count: {
        let n = Math.max(Settings.workspaces, root.activeId)
        for (const ws of Hyprland.workspaces.values) n = Math.max(n, ws.id)
        return n
    }

    readonly property real step: Math.max(root.slotWidth, root.activeWidth) + root.spacing

    implicitWidth: root.count * root.step - root.spacing
    implicitHeight: root.activeHeight

    function go(id: int): void {
        if (id >= 1 && id !== root.activeId) Hyprland.dispatch("workspace " + id)
    }

    Repeater {
        model: root.count

        Rectangle {
            id: slot
            required property int index
            readonly property int wsId: index + 1
            readonly property bool used: root.occupied[wsId] === true

            x: index * root.step + (root.step - root.spacing - width) / 2
            anchors.verticalCenter: parent.verticalCenter
            width: root.slotWidth
            height: used ? root.activeHeight * 0.65 : root.slotWidth
            radius: width / 2
            color: root.color
            opacity: used ? 0.55 : 0.22

            Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 180 } }

            MouseArea {
                // Bigger hit area than the dot itself.
                anchors.centerIn: parent
                width: root.step; height: root.activeHeight + 8
                onClicked: root.go(slot.wsId)
            }
        }
    }

    Rectangle {
        id: highlight
        readonly property int slotIndex: root.activeId - 1

        x: slotIndex * root.step + (root.step - root.spacing - width) / 2
        anchors.verticalCenter: parent.verticalCenter
        width: root.activeWidth
        height: root.activeHeight
        radius: width / 2
        color: root.color

        Behavior on x {
            NumberAnimation { duration: 240; easing.type: Easing.OutQuint }
        }
    }

    // Touchpads send many small deltas; step once per mouse-wheel notch
    // (120) worth of scrolling.
    property real wheelAcc: 0
    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: ev => {
            root.wheelAcc += ev.angleDelta.y !== 0 ? ev.angleDelta.y : -ev.angleDelta.x
            if (root.wheelAcc <= -120) {
                root.wheelAcc = 0
                root.go(Math.min(root.count, root.activeId + 1))
            } else if (root.wheelAcc >= 120) {
                root.wheelAcc = 0
                root.go(root.activeId - 1)
            }
        }
    }
}

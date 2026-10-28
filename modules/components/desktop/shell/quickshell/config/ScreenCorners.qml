import QtQuick
import Quickshell
import Quickshell.Wayland

Scope {
    id: root

    // Layout pixels, so the curve follows the display's configured scale.
    readonly property int cornerRadius: 20

    Variants {
        // Only round laptop panels. External monitors keep their own shape.
        model: Quickshell.screens.filter(screen => screen.name.startsWith("eDP"))

        delegate: Scope {
            id: output
            required property ShellScreen modelData

            Variants {
                model: [0, 1, 2, 3]

                delegate: PanelWindow {
                    id: corner
                    required property int modelData

                    screen: output.modelData
                    implicitWidth: root.cornerRadius
                    implicitHeight: root.cornerRadius
                    color: "transparent"

                    anchors {
                        top: corner.modelData < 2
                        bottom: corner.modelData >= 2
                        left: corner.modelData % 2 === 0
                        right: corner.modelData % 2 === 1
                    }

                    // Ignore panel reservations and draw at the physical edge.
                    exclusionMode: ExclusionMode.Ignore
                    WlrLayershell.layer: WlrLayer.Overlay
                    WlrLayershell.namespace: "nixc-screen-corner"
                    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                    // An empty input region lets all pointer events pass through.
                    mask: Region {}

                    Canvas {
                        anchors.fill: parent
                        antialiasing: true
                        rotation: [0, 90, 270, 180][corner.modelData]

                        onPaint: {
                            const ctx = getContext("2d")
                            const r = width
                            ctx.clearRect(0, 0, width, height)
                            ctx.beginPath()
                            ctx.moveTo(0, 0)
                            ctx.lineTo(r, 0)
                            ctx.arc(r, r, r, -Math.PI / 2, -Math.PI, true)
                            ctx.closePath()
                            ctx.fillStyle = "#000000"
                            ctx.fill()
                        }
                    }
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Shapes

// A panel attached to a screen edge: flat on the edge side, rounded on the
// other, with concave fillets where it meets the edge (the curve flowing
// into the screen border).
//
// The item is `bodyWidth + 2 * fillet` wide; the body sits in the middle.
// `edge: "bottom"` mirrors it for sheets rising from the bottom.
//
// Drawn with QtQuick.Shapes (CurveRenderer = GPU curves, antialiased), so
// animating bodyWidth/bodyHeight/radius just re-runs the path each frame --
// no Canvas repaint, no flicker.
Shape {
    id: root

    property real bodyWidth: 200
    property real bodyHeight: 40
    property real radius: 18
    property real fillet: 14
    property color color: "black"
    property string edge: "top"

    width: bodyWidth + 2 * fillet
    height: bodyHeight

    // Keep the curves valid while the shape is tiny (mid-animation).
    readonly property real f: Math.max(0, Math.min(fillet, bodyHeight / 2))
    readonly property real r: Math.max(0, Math.min(radius, bodyWidth / 2, bodyHeight - f))
    readonly property real x0: fillet
    readonly property real x1: fillet + bodyWidth
    readonly property real h: bodyHeight

    preferredRendererType: Shape.CurveRenderer

    transform: Scale {
        origin.y: root.height / 2
        yScale: root.edge === "bottom" ? -1 : 1
    }

    ShapePath {
        fillColor: root.color
        strokeWidth: -1
        strokeColor: "transparent"

        startX: root.x0 - root.f; startY: 0

        // Left fillet: screen edge -> body side.
        PathArc { x: root.x0; y: root.f; radiusX: root.f; radiusY: root.f; direction: PathArc.Clockwise }
        PathLine { x: root.x0; y: root.h - root.r }
        // Bottom-left corner.
        PathArc { x: root.x0 + root.r; y: root.h; radiusX: root.r; radiusY: root.r; direction: PathArc.Counterclockwise }
        PathLine { x: root.x1 - root.r; y: root.h }
        // Bottom-right corner.
        PathArc { x: root.x1; y: root.h - root.r; radiusX: root.r; radiusY: root.r; direction: PathArc.Counterclockwise }
        PathLine { x: root.x1; y: root.f }
        // Right fillet: body side -> screen edge.
        PathArc { x: root.x1 + root.f; y: 0; radiusX: root.f; radiusY: root.f; direction: PathArc.Clockwise }
        PathLine { x: root.x0 - root.f; y: 0 }
    }
}

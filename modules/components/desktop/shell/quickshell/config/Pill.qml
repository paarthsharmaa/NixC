pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io
import "panels"
import "services"

// The top island. One surface, one animated body that every state morphs
// into:
//   ""          collapsed: workspaces · clock · wifi/battery
//   "expanded"  click the island: window, workspaces, clock+date, status
//   "osd"       volume/brightness
//   <panel>     launcher, control center, wallpaper, ...
//
// Settings.barStyle picks how the body is drawn:
//   "notch" -- attached to the top edge (NotchShape, curves into the edge)
//   "pill"  -- the older floating pill
//
// Smoothness: the window never resizes (full screen height + input mask),
// only the body's width/height/radius animate. Panel content is laid out at
// its final size and revealed by the growing (clipped) body, so it never
// squeezes or re-lays out mid-animation.
//
// Focus: hyprwm/Hyprland#8293 -- mutating WlrKeyboardFocus on a mapped
// layer surface skips Hyprland's refocus path. So keyboardFocus stays
// static (OnDemand), a HyprlandFocusGrab takes the keyboard while a panel
// is open, and on close focus is handed back to the previously active
// window with `focuswindow address:...` (a real focus change, no workspace
// bounce). The first-login case is handled in shell.qml.
PanelWindow {
    id: root
    required property var screen

    property string panel:      ""
    property bool   osdVisible: false
    property string osdType:    ""

    signal dismiss()
    signal request(string name)

    readonly property bool notch: Settings.barStyle !== "pill"

    anchors { top: true; left: true; right: true }
    implicitHeight: screen?.height ?? 1080
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell:pill"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand // must stay static, see header
    WlrLayershell.exclusiveZone: root.notch ? root.dimMap[""].h : 60

    readonly property var dimMap: ({
        "":               root.notch ? { w: 300, h: 36, r: 18 } : { w: 260, h: 48, r: 24 },
        "osd":            root.notch ? { w: 360, h: 36, r: 18 } : { w: 340, h: 48, r: 24 },
        "expanded":       { w: 760, h: 84,  r: 26 },
        "launcher":       { w: 600, h: 460, r: 28 }, // 16+50+10 + 6 rows (58+4) + 16
        "scriptlauncher": { w: 600, h: 420, r: 28 },
        "controlcenter":  { w: 600, h: 860, r: 28 },
        "sysinfo":        { w: 540, h: 460, r: 28 },
        "power":          { w: 360, h: 200, r: 28 },
        "wallpaper":      { w: 680, h: 590, r: 28 },
        "media":          { w: 480, h: 280, r: 28 },
        "powerprofile":   { w: 540, h: 460, r: 28 },
        "visualizer":     { w: 520, h: 220, r: 28 }
    })

    readonly property string effectiveState:
        (panel === "" && osdVisible) ? "osd" : panel

    readonly property var dim: dimMap[effectiveState] ?? dimMap[""]

    // ── Focus handling (see header) ──────────────────────────────────────
    property string preOpenWindowAddress: ""

    HyprlandFocusGrab {
        windows: [root]
        active:  root.panel !== ""
        onActiveChanged: {
            // Captured before the grab takes focus away.
            if (active) root.preOpenWindowAddress = Hyprland.activeWindow?.address ?? ""
        }
        onCleared: root.dismiss()
    }

    // panel goes back to "" via IPC, Escape, or clicking outside; all need it.
    onPanelChanged: {
        if (root.panel === "" && root.preOpenWindowAddress !== "") {
            const addr = root.preOpenWindowAddress
            root.preOpenWindowAddress = ""
            Qt.callLater(() => Hyprland.dispatch("focuswindow address:" + addr))
        }
    }

    // ── Shared state for the bar contents ────────────────────────────────
    SystemClock { id: clock; precision: SystemClock.Minutes }

    // swaync pushes {"count":N,"dnd":bool,...} on every change.
    property int  notifCount: 0
    property bool notifDnd: false
    Process {
        id: notifWatch
        running: true
        command: ["swaync-client", "-s"]
        stdout: SplitParser {
            onRead: line => {
                try {
                    const s = JSON.parse(line)
                    root.notifCount = s.count ?? 0
                    root.notifDnd = s.dnd ?? false
                } catch (e) {}
            }
        }
        // swaync restarted or wasn't up yet: try again shortly.
        onExited: notifRetry.start()
    }
    Timer { id: notifRetry; interval: 3000; onTriggered: notifWatch.running = true }

    readonly property var activeApp: ToplevelManager.activeToplevel
    readonly property var activeEntry: activeApp ? DesktopEntries.heuristicLookup(activeApp.appId) : null

    // ── Animated body ────────────────────────────────────────────────────
    // Material 3 "emphasized decelerate": fast start, long soft landing.
    component Motion: NumberAnimation {
        duration: Settings.motion
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.05, 0.7, 0.1, 1.0, 1.0, 1.0]
    }

    property real bodyW: dim.w
    property real bodyH: dim.h
    property real bodyR: dim.r
    Behavior on bodyW { Motion {} }
    Behavior on bodyH { Motion {} }
    Behavior on bodyR { Motion {} }

    readonly property real topGap: root.notch ? 0 : 12
    readonly property color fill:
        (root.notch && Settings.notchColor === "black") ? "#000000" : Colors.background

    readonly property bool isFullscreen:
        Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.hasFullscreen : false

    Item {
        id: visual
        anchors.fill: parent
        opacity: root.isFullscreen ? 0.0 : 1.0
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        NotchShape {
            visible: root.notch
            x: (root.width - width) / 2
            y: 0
            bodyWidth: root.bodyW
            bodyHeight: root.bodyH
            radius: root.bodyR
            fillet: 14
            color: root.fill
        }

        // Pill style: soft offset shadow + floating rounded rectangle.
        Rectangle {
            visible: !root.notch
            x: body.x; y: body.y + 4
            width: body.width; height: body.height
            radius: root.bodyR
            opacity: 0.32
            color: "#000000"
        }
        Rectangle {
            visible: !root.notch
            x: body.x; y: body.y
            width: body.width; height: body.height
            radius: root.bodyR
            color: root.fill
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.09)
        }

        // Content area = the body. Clipped, so content laid out at its
        // final size is revealed as the body grows.
        Item {
            id: body
            x: (root.width - root.bodyW) / 2
            y: root.topGap
            width: root.bodyW
            height: root.bodyH
            clip: true

            // Click the collapsed island to expand it; click the expanded
            // bar's background to collapse it again.
            MouseArea {
                anchors.fill: parent
                enabled: root.effectiveState === "" || root.panel === "expanded"
                cursorShape: root.effectiveState === "" ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.panel === "expanded" ? root.dismiss() : root.request("expanded")
            }

            // ── Collapsed ─────────────────────────────────────────────────
            Item {
                anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
                width: root.dimMap[""].w; height: root.dimMap[""].h
                opacity: root.effectiveState === "" ? 1.0 : 0.0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

                Workspaces {
                    anchors { left: parent.left; leftMargin: 18; verticalCenter: parent.verticalCenter }
                    slotWidth: 5; spacing: 4; activeWidth: 7; activeHeight: 14
                }

                Text {
                    anchors.centerIn: parent
                    text: Qt.formatTime(clock.date, "hh:mm")
                    color: Colors.foreground
                    font { pixelSize: root.notch ? 15 : 20; bold: true; family: "JetBrainsMono Nerd Font" }
                }

                Row {
                    anchors { right: parent.right; rightMargin: 18; verticalCenter: parent.verticalCenter }
                    spacing: 8
                    Text {
                        text: Network.icon
                        color: Colors.foreground
                        font { pixelSize: 14; family: "JetBrainsMono Nerd Font" }
                    }
                    Text {
                        visible: Battery.present
                        text: Battery.icon
                        color: Battery.critical ? Colors.critical : Colors.foreground
                        font { pixelSize: 14; family: "JetBrainsMono Nerd Font" }
                        SequentialAnimation on opacity {
                            running: Battery.critical; loops: Animation.Infinite
                            NumberAnimation { to: 0.3; duration: 800; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutSine }
                        }
                    }
                }
            }

            // ── Expanded ──────────────────────────────────────────────────
            FocusScope {
                id: expanded
                anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
                width: root.dimMap.expanded.w; height: root.dimMap.expanded.h
                opacity: root.panel === "expanded" ? 1.0 : 0.0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

                onVisibleChanged: if (root.panel === "expanded") forceActiveFocus()
                Keys.onEscapePressed: ev => { root.dismiss(); ev.accepted = true }

                readonly property real side: 24

                // Left: active window, workspaces.
                Column {
                    anchors { left: parent.left; leftMargin: expanded.side; verticalCenter: parent.verticalCenter }
                    spacing: 10

                    Row {
                        spacing: 8
                        IconImage {
                            anchors.verticalCenter: parent.verticalCenter
                            implicitSize: 18
                            visible: root.activeApp !== null
                            source: Quickshell.iconPath(root.activeEntry?.icon ?? root.activeApp?.appId ?? "",
                                                        "application-x-executable")
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: Math.min(implicitWidth, 220)
                            elide: Text.ElideRight
                            text: root.activeEntry?.name ?? root.activeApp?.appId ?? "Desktop"
                            color: Colors.foreground
                            font { pixelSize: 14; weight: Font.DemiBold; family: "JetBrainsMono Nerd Font" }
                        }
                    }

                    Workspaces {}
                }

                // Center: clock + date.
                Row {
                    anchors.centerIn: parent
                    spacing: 12
                    Text {
                        anchors.baseline: date.baseline
                        text: Qt.formatTime(clock.date, "hh:mm")
                        color: Colors.foreground
                        font { pixelSize: 28; bold: true; family: "JetBrainsMono Nerd Font" }
                    }
                    Text {
                        id: date
                        anchors.verticalCenter: parent.verticalCenter
                        text: Qt.formatDate(clock.date, "ddd, MMM d")
                        color: Colors.dim
                        font { pixelSize: 14; family: "JetBrainsMono Nerd Font" }
                    }
                }

                // Right: notifications, wifi, battery.
                Column {
                    anchors { right: parent.right; rightMargin: expanded.side; verticalCenter: parent.verticalCenter }
                    spacing: 10

                    Item {
                        anchors.right: parent.right
                        width: notifRow.implicitWidth; height: notifRow.implicitHeight

                        Row {
                            id: notifRow
                            spacing: 8
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.notifDnd ? "Do not disturb"
                                    : root.notifCount === 0 ? "All caught up"
                                    : root.notifCount + (root.notifCount === 1 ? " notification" : " notifications")
                                color: Colors.foreground
                                font { pixelSize: 13; family: "JetBrainsMono Nerd Font" }
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.notifDnd ? "󰂛" : root.notifCount > 0 ? "󰂚" : "󰂜"
                                color: root.notifCount > 0 && !root.notifDnd ? Colors.accent : Colors.foreground
                                font { pixelSize: 15; family: "JetBrainsMono Nerd Font" }
                            }
                        }

                        // Open the notification center; the island collapses.
                        MouseArea {
                            anchors { fill: parent; margins: -6 }
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.dismiss()
                                Quickshell.execDetached(["swaync-client", "-t", "-sw"])
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        spacing: 10
                        Text {
                            text: Network.icon
                            color: Colors.foreground
                            font { pixelSize: 15; family: "JetBrainsMono Nerd Font" }
                        }
                        Text {
                            visible: Battery.present
                            text: Battery.icon + " " + Battery.percent + "%"
                            color: Battery.critical ? Colors.critical : Colors.foreground
                            font { pixelSize: 13; family: "JetBrainsMono Nerd Font" }
                        }
                    }
                }
            }

            // ── OSD ───────────────────────────────────────────────────────
            Item {
                anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
                width: root.dimMap.osd.w; height: root.dimMap.osd.h
                opacity: root.effectiveState === "osd" ? 1.0 : 0.0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

                Row {
                    anchors.centerIn: parent; spacing: 12
                    Text {
                        text: root.osdType === "volume" ? (Audio.muted ? "󰖁" : "󰕾") : "󰃟"
                        color: Colors.foreground
                        font { pixelSize: 18; bold: true; family: "JetBrainsMono Nerd Font" }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Rectangle {
                        id: osdTrack; width: 200; height: 5; radius: 3; color: Colors.color0
                        anchors.verticalCenter: parent.verticalCenter
                        Rectangle {
                            id: osdFill
                            width: Math.max(0, Math.min(osdTrack.width, osdTrack.width * (
                                root.osdType === "volume" ? (Audio.muted ? 0 : Audio.volume / 100) : (Bright.percent / 100)
                            )))
                            height: parent.height; radius: 2; color: Colors.color4
                        }
                        Rectangle {
                            x: Math.max(0, Math.min(osdTrack.width - width, osdFill.width - width / 2))
                            anchors.verticalCenter: parent.verticalCenter
                            width: 10; height: 10; radius: 5; color: Colors.foreground
                        }
                    }
                    Text {
                        text: root.osdType === "volume" ? (Audio.muted ? "muted" : Audio.volume + "%") : (Bright.percent + "%")
                        color: Colors.color8
                        font { pixelSize: 14; family: "JetBrainsMono Nerd Font" }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // ── Panels ────────────────────────────────────────────────────
            // Each loads when opened and stays alive until its fade-out has
            // finished, so closing fades instead of blinking out.
            Component { id: launcherC;       LauncherContent       { onDismiss: root.dismiss() } }
            Component { id: scriptlauncherC; ScriptLauncherContent { onDismiss: root.dismiss() } }
            Component { id: controlcenterC;  ControlCenterContent  { onDismiss: root.dismiss() } }
            Component { id: sysinfoC;        SysInfoContent        { onDismiss: root.dismiss() } }
            Component { id: powerC;          PowerContent          { onDismiss: root.dismiss() } }
            Component { id: mediaC;          MediaContent          { onDismiss: root.dismiss() } }
            Component { id: powerprofileC;   PowerProfileContent   { onDismiss: root.dismiss() } }
            Component { id: visualizerC;     VisualizerContent     { onDismiss: root.dismiss() } }

            Repeater {
                model: [
                    { name: "launcher",       comp: launcherC },
                    { name: "scriptlauncher", comp: scriptlauncherC },
                    { name: "controlcenter",  comp: controlcenterC },
                    { name: "sysinfo",        comp: sysinfoC },
                    { name: "power",          comp: powerC },
                    { name: "media",          comp: mediaC },
                    { name: "powerprofile",   comp: powerprofileC },
                    { name: "visualizer",     comp: visualizerC }
                ]

                Loader {
                    id: pl
                    required property var modelData
                    readonly property bool shown: root.panel === pl.modelData.name
                    anchors { top: parent?.top; horizontalCenter: parent?.horizontalCenter }
                    width: root.dimMap[pl.modelData.name].w
                    height: root.dimMap[pl.modelData.name].h
                    sourceComponent: pl.modelData.comp
                    active: shown || opacity > 0.01
                    opacity: shown ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                }
            }

            // Wallpaper stays loaded for good: rebuilding its grid of async
            // Image delegates on every open flashed placeholder tiles.
            Loader {
                anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
                width: root.dimMap.wallpaper.w; height: root.dimMap.wallpaper.h
                active: true
                opacity: root.panel === "wallpaper" ? 1.0 : 0.0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                sourceComponent: WallpaperContent {
                    onDismiss: root.dismiss()
                    panelVisible: root.panel === "wallpaper"
                }
            }
        }
    }

    Region { id: bodyMask; item: body }
    mask: bodyMask

    // Services only poll while something on screen reads them.
    Binding { target: SysStats; property: "live"; value: root.panel === "sysinfo" }
    Binding { target: Network;  property: "live"; value: root.panel === "controlcenter" }
}

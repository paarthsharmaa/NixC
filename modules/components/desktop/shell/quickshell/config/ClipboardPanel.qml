pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "services"

// Clipboard history: a sheet at the bottom edge of the screen, search and
// history on the left, preview on the right. Same colors/shapes as the
// pill and control center (Colors.background, color0 cards, 28px corners).
//
// Data comes from `clipboard-helper` (modules/components/desktop/services/
// clipboard): cliphist for the history, plus rendered previews for images,
// PDFs, office files and videos.
//
// The window only exists while open (LazyLoader). Hyprland slides it in
// and out (layer rule "clipboard-slide" in hyprland/config/common/rules.lua),
// so there's no QML animation and no close delay to manage.
Scope {
    id: root

    property bool open: false

    // ── History ───────────────────────────────────────────────────────────
    property var entries: [] // [{ id, text, kind }]
    property string query: ""

    readonly property var filtered: {
        const q = root.query.trim().toLowerCase()
        if (q === "") return root.entries
        return root.entries.filter(e => e.text.toLowerCase().includes(q))
    }

    function kindOf(text: string): string {
        if (text.startsWith("[[ binary data")) return "image"
        if (text.startsWith("file://"))        return "file"
        if (/^https?:\/\/\S+$/.test(text))     return "link"
        if (/^#?([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/.test(text)) return "color"
        return "text"
    }

    // Copied files show up as URIs ("file:///a/b%20c.png file:///..."):
    // list them by file name, "+N" for the rest.
    function fileLabel(text: string): string {
        const uris = text.split(/\s+/).filter(u => u.startsWith("file://"))
        let name = (uris[0] ?? text).replace(/^file:\/\//, "").replace(/\/$/, "")
        try { name = decodeURIComponent(name) } catch (e) {}
        name = name.slice(name.lastIndexOf("/") + 1)
        return uris.length > 1 ? name + "  +" + (uris.length - 1) : name
    }

    function iconOf(kind: string): string {
        switch (kind) {
        case "image": return "󰋩"
        case "file":  return "󰈙"
        case "dir":   return "󰉋"
        case "link":  return "󰌹"
        case "color": return "󰏘"
        default:      return "󰦨"
        }
    }

    Process {
        id: listProc
        command: ["clipboard-helper", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = []
                for (const line of this.text.split("\n")) {
                    const tab = line.indexOf("\t")
                    if (tab <= 0) continue
                    const text = line.slice(tab + 1)
                    out.push({ id: line.slice(0, tab), text: text, kind: root.kindOf(text) })
                }
                root.entries = out
            }
        }
    }

    // ── Preview ───────────────────────────────────────────────────────────
    property string previewId: ""
    property string previewKind: ""
    property string previewMeta: ""
    property string previewImage: ""
    property string previewBody: ""
    property bool   previewLoading: false
    // Only slow renders (office files, first PDF page) dim the old preview
    // and show "Rendering preview…"; fast ones would just flicker.
    property bool   previewSlow: false
    onPreviewLoadingChanged: {
        if (previewLoading) slowTimer.restart()
        else { slowTimer.stop(); previewSlow = false }
    }
    Timer { id: slowTimer; interval: 250; onTriggered: root.previewSlow = true }

    // Selection moves fast while holding an arrow key: wait until it
    // settles, run one preview at a time, then catch up with the latest.
    property string wantedId: ""

    function requestPreview(id: string): void {
        root.wantedId = id
        if (id === "") {
            root.previewKind = ""; root.previewMeta = ""; root.previewImage = ""; root.previewBody = ""
            return
        }
        previewDebounce.restart()
    }

    Timer {
        id: previewDebounce
        interval: 90
        onTriggered: {
            if (previewProc.running || root.wantedId === root.previewId) return
            root.previewId = root.wantedId
            root.previewLoading = true
            previewProc.command = ["clipboard-helper", "preview", root.previewId]
            previewProc.running = true
        }
    }

    Process {
        id: previewProc
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.split("\n")
                root.previewKind  = lines[0] ?? ""
                root.previewMeta  = lines[1] ?? ""
                root.previewImage = lines[2] ?? ""
                root.previewBody  = lines.slice(3).join("\n")
            }
        }
        onExited: {
            root.previewLoading = false
            // The selection moved on while this one was rendering.
            if (root.wantedId !== root.previewId) previewDebounce.restart()
        }
    }

    // ── Actions ───────────────────────────────────────────────────────────
    function copy(id: string): void {
        if (id === "") return
        Quickshell.execDetached(["clipboard-helper", "copy", id])
        root.open = false
    }

    function remove(id: string): void {
        if (id === "") return
        Quickshell.execDetached(["clipboard-helper", "delete", id])
        root.entries = root.entries.filter(e => e.id !== id)
        root.previewId = ""
    }

    // Hand keyboard focus back to the window that had it (same reason as
    // Pill.qml's preOpenWindowAddress: hyprwm/Hyprland#8293).
    property string prevWindow: ""

    onOpenChanged: {
        if (open) {
            root.prevWindow = Hyprland.activeWindow?.address ?? ""
            root.query = ""
            root.previewId = ""
            root.wantedId = ""
            listProc.running = true
        } else if (root.prevWindow !== "") {
            const addr = root.prevWindow
            root.prevWindow = ""
            Qt.callLater(() => Hyprland.dispatch("focuswindow address:" + addr))
        }
    }

    LazyLoader {
        active: root.open

        PanelWindow {
            id: win

            screen: Quickshell.screens[0]
            anchors.bottom: true
            implicitWidth: 960
            implicitHeight: 480
            color: "transparent"

            // Sit on the bottom edge even if something reserves space there.
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell:clipboard"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            // Clicking anywhere outside the sheet closes it.
            HyprlandFocusGrab {
                windows: [win]
                active: true
                onCleared: root.open = false
            }

            Rectangle {
                id: sheet
                anchors.fill: parent

                color: Colors.background
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.09)
                topLeftRadius: 28
                topRightRadius: 28
                // Flush with the screen edge at the bottom.
                bottomLeftRadius: 0
                bottomRightRadius: 0

                FocusScope {
                    anchors { fill: parent; margins: 18 }
                    focus: true

                    // ── Search ────────────────────────────────────────────
                    Rectangle {
                        id: searchBox
                        anchors { top: parent.top; left: parent.left; right: parent.right }
                        height: 48; radius: 14; color: Colors.color0
                        border.width: search.activeFocus ? 1 : 0; border.color: Colors.color8

                        Text {
                            id: searchIcon
                            anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                            text: "󰅌"; color: Colors.color8
                            font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"
                        }

                        TextInput {
                            id: search
                            anchors {
                                left: searchIcon.right; leftMargin: 12
                                right: hints.left; rightMargin: 12
                                top: parent.top; bottom: parent.bottom
                            }
                            verticalAlignment: TextInput.AlignVCenter
                            color: Colors.foreground; selectionColor: Colors.color8; clip: true
                            font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font"
                            focus: true
                            Component.onCompleted: forceActiveFocus()

                            onTextChanged: { root.query = text; list.currentIndex = 0 }

                            Keys.onEscapePressed: ev => { root.open = false; ev.accepted = true }
                            Keys.onReturnPressed: ev => { root.copy(list.currentId); ev.accepted = true }
                            Keys.onEnterPressed:  ev => { root.copy(list.currentId); ev.accepted = true }
                            Keys.onDownPressed:   ev => { list.incrementCurrentIndex(); ev.accepted = true }
                            Keys.onUpPressed:     ev => { list.decrementCurrentIndex(); ev.accepted = true }
                            Keys.onPressed: ev => {
                                if (ev.key === Qt.Key_PageDown) {
                                    list.currentIndex = Math.min(list.count - 1, list.currentIndex + 8); ev.accepted = true
                                } else if (ev.key === Qt.Key_PageUp) {
                                    list.currentIndex = Math.max(0, list.currentIndex - 8); ev.accepted = true
                                } else if (ev.key === Qt.Key_Delete && (ev.modifiers & Qt.ShiftModifier)) {
                                    root.remove(list.currentId); ev.accepted = true
                                }
                            }

                            Text {
                                visible: search.text.length === 0
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Search clipboard…"; color: Colors.color8; font: search.font
                            }
                        }

                        Text {
                            id: hints
                            anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                            text: root.filtered.length + "   enter copy · shift+del remove · esc close"
                            color: Colors.color8; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    // ── History list ──────────────────────────────────────
                    ListView {
                        id: list
                        anchors {
                            top: searchBox.bottom; topMargin: 12
                            left: parent.left; bottom: parent.bottom
                        }
                        width: 400
                        clip: true
                        spacing: 2
                        boundsBehavior: Flickable.StopAtBounds
                        highlightMoveDuration: 0
                        model: root.filtered

                        readonly property string currentId:
                            root.filtered[currentIndex]?.id ?? ""
                        onCurrentIdChanged: root.requestPreview(currentId)

                        delegate: Rectangle {
                            id: row
                            required property var modelData
                            required property int index
                            readonly property bool current: list.currentIndex === row.index

                            width: list.width; height: 42; radius: 12
                            color: (rowHover.containsMouse || row.current) ? Colors.color0 : "transparent"
                            Behavior on color { ColorAnimation { duration: 80 } }

                            Rectangle {
                                width: 3; height: 20; radius: 2
                                anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                                color: row.current ? Colors.foreground : "transparent"
                            }

                            Text {
                                id: rowIcon
                                anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                                width: 20
                                text: root.iconOf(row.modelData.kind)
                                color: row.current ? Colors.accent : Colors.color8
                                font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font"
                            }

                            Text {
                                anchors {
                                    left: rowIcon.right; leftMargin: 10
                                    right: parent.right; rightMargin: 12
                                    verticalCenter: parent.verticalCenter
                                }
                                text: row.modelData.kind === "file"
                                    ? root.fileLabel(row.modelData.text) : row.modelData.text
                                textFormat: Text.PlainText
                                maximumLineCount: 1
                                elide: Text.ElideRight
                                color: Colors.foreground
                                font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"
                            }

                            MouseArea {
                                id: rowHover
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: list.currentIndex = row.index
                                onDoubleClicked: root.copy(row.modelData.id)
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: list.count === 0
                            text: root.entries.length === 0 ? "Clipboard is empty" : "No matches"
                            color: Colors.color8; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    // ── Preview ───────────────────────────────────────────
                    Rectangle {
                        id: preview
                        anchors {
                            top: searchBox.bottom; topMargin: 12
                            left: list.right; leftMargin: 14
                            right: parent.right; bottom: parent.bottom
                        }
                        radius: 20
                        color: Colors.color0
                        clip: true

                        Text {
                            id: meta
                            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
                            text: root.previewMeta
                            color: Colors.color8; elide: Text.ElideMiddle
                            font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"
                        }

                        Item {
                            id: body
                            // Keep the old preview, dimmed, while the next renders.
                            opacity: root.previewSlow ? 0.35 : 1
                            Behavior on opacity { NumberAnimation { duration: 120 } }
                            anchors {
                                top: meta.bottom; topMargin: 10
                                left: parent.left; right: parent.right; bottom: parent.bottom
                                leftMargin: 16; rightMargin: 16; bottomMargin: 16
                            }

                            Image {
                                id: img
                                anchors.fill: parent
                                visible: root.previewImage !== "" && status === Image.Ready
                                source: root.previewImage === "" ? ""
                                    : "file://" + encodeURI(root.previewImage).replace(/#/g, "%23")
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                cache: false
                                smooth: true
                                mipmap: true
                                sourceSize { width: 1200; height: 1200 }
                            }

                            Rectangle {
                                visible: root.previewKind === "color"
                                anchors.centerIn: parent
                                width: 160; height: 160; radius: 28
                                color: root.previewBody.trim().startsWith("#")
                                    ? root.previewBody.trim() : "#" + root.previewBody.trim()
                                border.width: 1; border.color: Qt.rgba(1, 1, 1, 0.12)
                            }

                            Flickable {
                                anchors.fill: parent
                                visible: root.previewImage === "" && root.previewKind !== "color"
                                contentHeight: bodyText.implicitHeight
                                clip: true
                                boundsBehavior: Flickable.StopAtBounds

                                Text {
                                    id: bodyText
                                    width: parent.width
                                    text: root.previewBody
                                    textFormat: Text.PlainText
                                    wrapMode: Text.WrapAnywhere
                                    color: root.previewKind === "link" ? Colors.accent : Colors.foreground
                                    font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font"
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: !root.previewLoading && root.previewKind === "file" && root.previewBody === ""
                                text: "󰈔\nNo preview"
                                horizontalAlignment: Text.AlignHCenter
                                color: Colors.color8; font.pixelSize: 15; font.family: "JetBrainsMono Nerd Font"
                            }
                        }

                        // Outside `body` so it isn't dimmed with it.
                        Rectangle {
                            anchors.centerIn: parent
                            visible: root.previewSlow
                            width: loadingText.implicitWidth + 32; height: 36; radius: 18
                            color: Colors.background
                            Text {
                                id: loadingText
                                anchors.centerIn: parent
                                text: "Rendering preview…"
                                color: Colors.foreground; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                    }
                }
            }
        }
    }
}

pragma Singleton

import QtQuick
import Quickshell.Services.Pipewire

Item {
    id: root

    // Kept temporarily so existing panel bindings don't break.
    property bool live: false

    readonly property var sink:
        Pipewire.defaultAudioSink

    PwObjectTracker {
        objects: [
            root.sink
        ]
    }

    readonly property var audio:
        root.sink
            ? root.sink.audio
            : null

    readonly property int volume:
        root.audio
            ? Math.round(
                Math.min(
                    1.0,
                    root.audio.volume
                ) * 100
              )
            : 0

    readonly property bool muted:
        root.audio
            ? root.audio.muted
            : false

    function setVolume(value: int): void {
        if (!root.audio)
            return

        root.audio.volume =
            Math.max(
                0,
                Math.min(100, value)
            ) / 100
    }

    function toggleMute(): void {
        if (!root.audio)
            return

        root.audio.muted =
            !root.audio.muted
    }

    // Existing OSD IPC may continue calling this.
    // PipeWire state is already reactive.
    function refresh(): void {}
}

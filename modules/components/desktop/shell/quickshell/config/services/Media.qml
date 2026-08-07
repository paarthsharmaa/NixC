pragma Singleton

import QtQuick
import Quickshell.Services.Mpris

Item {
    id: root

    property bool live: false

    readonly property var player: {
        const players =
            Mpris.players.values

        for (let i = 0;
             i < players.length;
             ++i) {
            if (players[i].isPlaying)
                return players[i]
        }

        return players.length > 0
            ? players[0]
            : null
    }

    readonly property string title:
        root.player
            ? root.player.trackTitle
            : ""

    readonly property string artist:
        root.player
            ? root.player.trackArtist
            : ""

    readonly property string artUrl:
        root.player
            ? root.player.trackArtUrl
            : ""

    readonly property int position:
        root.player
            ? Math.floor(root.player.position)
            : 0

    readonly property int length:
        root.player
            ? Math.floor(root.player.length)
            : 0

    readonly property bool playing:
        root.player
            ? root.player.isPlaying
            : false

    readonly property string status:
        !root.player
            ? "Stopped"
            : root.player.isPlaying
                ? "Playing"
                : "Paused"

    function play(): void {
        if (root.player?.canPlay)
            root.player.play()
    }

    function pause(): void {
        if (root.player?.canPause)
            root.player.pause()
    }

    function toggle(): void {
        if (root.player?.canTogglePlaying)
            root.player.togglePlaying()
    }

    function next(): void {
        if (root.player?.canGoNext)
            root.player.next()
    }

    function prev(): void {
        if (root.player?.canGoPrevious)
            root.player.previous()
    }

    function seekTo(seconds: int): void {
        if (!root.player
            || !root.player.canSeek
            || !root.player.positionSupported)
            return

        root.player.position =
            Math.max(
                0,
                Math.min(
                    root.length,
                    seconds
                )
            )
    }

    // MPRIS avoids pushing continuous position updates
    // unless somebody is watching it.
    Timer {
        interval: 1000
        repeat: true

        running:
            root.live
            && root.player
            && root.player.isPlaying

        onTriggered: {
            if (root.player)
                root.player.positionChanged()
        }
    }
}

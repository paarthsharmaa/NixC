pragma Singleton

import QtQuick
import Quickshell.Io
import Quickshell.Networking as QsNet

Item {
    id: root

    property bool live: false
    property string ipAddr: ""

    readonly property var wifiDevice: {
        const devices =
            QsNet.Networking.devices.values

        for (let i = 0;
             i < devices.length;
             ++i) {
            if (devices[i].type
                === QsNet.DeviceType.Wifi)
                return devices[i]
        }

        return null
    }

    readonly property var activeNetwork: {
        if (!root.wifiDevice)
            return null

        const networks =
            root.wifiDevice.networks.values

        for (let i = 0;
             i < networks.length;
             ++i) {
            if (networks[i].connected)
                return networks[i]
        }

        return null
    }

    readonly property string ssid:
        root.activeNetwork
            ? root.activeNetwork.name
            : ""

    readonly property string strength:
        root.activeNetwork
            ? String(
                Math.round(
                    root.activeNetwork.signalStrength
                    * 100
                )
              )
            : "0"

    readonly property bool connected:
        root.activeNetwork !== null

    readonly property string icon: {
        if (!root.connected)
            return "󰤭"

        const value =
            parseInt(root.strength)

        if (value >= 75) return "󰤨"
        if (value >= 50) return "󰤥"
        if (value >= 25) return "󰤢"

        return "󰤟"
    }

    function refreshIp(): void {
        root.ipAddr = ""

        if (!root.live
            || !root.connected
            || !root.wifiDevice)
            return

        ipPoll.command = [
            "ip",
            "-4",
            "-o",
            "addr",
            "show",
            "dev",
            root.wifiDevice.name,
            "scope",
            "global"
        ]

        ipPoll.running = true
    }

    onLiveChanged: {
        if (root.wifiDevice)
            root.wifiDevice.scannerEnabled =
                root.live

        if (root.live)
            root.refreshIp()
    }

    onWifiDeviceChanged: {
        if (root.wifiDevice)
            root.wifiDevice.scannerEnabled =
                root.live

        if (root.live)
            root.refreshIp()
    }

    onConnectedChanged: {
        if (root.live)
            root.refreshIp()
    }

    Process {
        id: ipPoll

        stdout: SplitParser {
            onRead: line => {
                const match =
                    line.match(
                        /\binet\s+([0-9.]+)\//
                    )

                if (match)
                    root.ipAddr =
                        match[1]
            }
        }
    }
}

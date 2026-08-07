pragma Singleton

import QtQuick
import Quickshell.Services.UPower as QsPower

Item {
    id: root

    readonly property var battery:
        QsPower.UPower.displayDevice

    readonly property bool present:
        root.battery.ready
        && root.battery.isPresent

    readonly property int percent:
        root.battery.ready
            ? Math.round(
                root.battery.percentage
              )
            : 0

    readonly property string status: {
        if (!root.battery.ready)
            return "Unknown"

        switch (root.battery.state) {
        case QsPower.UPowerDeviceState.Charging:
        case QsPower.UPowerDeviceState.PendingCharge:
            return "Charging"

        case QsPower.UPowerDeviceState.FullyCharged:
            return "Full"

        case QsPower.UPowerDeviceState.Discharging:
        case QsPower.UPowerDeviceState.PendingDischarge:
            return "Discharging"

        default:
            return "Unknown"
        }
    }

    readonly property bool charging:
        root.status === "Charging"
        || root.status === "Full"

    readonly property bool critical:
        root.percent <= 15
        && !root.charging

    readonly property string icon: {
        if (root.status === "Full")
            return "󰁹"

        if (root.status === "Charging") {
            if (root.percent >= 90) return "󰂅"
            if (root.percent >= 70) return "󰂄"
            if (root.percent >= 50) return "󰂃"
            if (root.percent >= 30) return "󰂂"
            return "󰢜"
        }

        if (root.percent >= 90) return "󰁹"
        if (root.percent >= 70) return "󰁾"
        if (root.percent >= 50) return "󰁽"
        if (root.percent >= 30) return "󰁻"
        if (root.percent >= 15) return "󰁺"

        return "󰂃"
    }

    readonly property color iconColor: {
        if (root.charging)
            return Colors.color2

        if (root.percent <= 15)
            return Colors.color1

        if (root.percent <= 30)
            return Colors.color3

        return Colors.foreground
    }
}

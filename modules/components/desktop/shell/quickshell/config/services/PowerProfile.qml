pragma Singleton

import QtQuick
import Quickshell.Services.UPower as QsPower

Item {
    id: root

    // Transitional compatibility with old ControlCenter.
    property bool live: false

    readonly property string current: {
        switch (QsPower.PowerProfiles.profile) {
        case QsPower.PowerProfile.PowerSaver:
            return "power-saver"

        case QsPower.PowerProfile.Performance:
            return "performance"

        default:
            return "balanced"
        }
    }

    readonly property var profiles:
        QsPower.PowerProfiles.hasPerformanceProfile
            ? [
                "power-saver",
                "balanced",
                "performance"
              ]
            : [
                "power-saver",
                "balanced"
              ]

    readonly property var icons: ({
        "power-saver": "󰌪",
        "balanced": "󰈐",
        "performance": "󰓅"
    })

    readonly property var labels: ({
        "power-saver": "Power Saver",
        "balanced": "Balanced",
        "performance": "Performance"
    })

    readonly property var colors: ({
        "power-saver": Colors.color5,
        "balanced": Colors.color7,
        "performance": Colors.foreground
    })

    function setProfile(profile: string): void {
        switch (profile) {
        case "power-saver":
            QsPower.PowerProfiles.profile =
                QsPower.PowerProfile.PowerSaver
            break

        case "performance":
            if (QsPower.PowerProfiles.hasPerformanceProfile)
                QsPower.PowerProfiles.profile =
                    QsPower.PowerProfile.Performance
            break

        default:
            QsPower.PowerProfiles.profile =
                QsPower.PowerProfile.Balanced
            break
        }
    }
}

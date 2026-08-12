pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property int percentage: 0
    property string status: ""


    Process {
        id: battery

        command: [
            "bash",
            "-c",
            "cat /sys/class/power_supply/BAT*/capacity; cat /sys/class/power_supply/BAT*/status"
        ]

        stdout: SplitParser {
            onRead: data => {
                let value = data.trim()

                if (value.match(/^[0-9]+$/))
                    root.percentage = parseInt(value)
                    else
                        root.status = value
            }
        }

        running: true
    }


    Timer {
        interval: 30000
        running: true
        repeat: true

        onTriggered: {
            battery.running = true
        }
    }
}

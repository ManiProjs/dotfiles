pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string name: "Offline"


    Process {
        id: network

        command: [
            "bash",
            "-c",
            "nmcli -t -f active,ssid dev wifi | awk -F: '$1==\"yes\" {print $2}'"
        ]

        stdout: SplitParser {
            onRead: data => {
                let value = data.trim()

                root.name =
                value.length > 0
                ? value
                : "Offline"
            }
        }

        running: true
    }


    Timer {
        interval: 10000
        running: true
        repeat: true

        onTriggered: {
            network.running = true
        }
    }
}

import QtQuick
import Quickshell.Io
import "../theme"

Label {
    id: root

    icon: "󰖩"
    value: "Offline"

    Process {
        id: network

        command: [
            "bash",
            "-c",
            "nmcli -t -f TYPE,NAME,STATE connection show --active"
        ]

        stdout: SplitParser {
            onRead: line => {
                if (!line || line.length === 0) {
                    root.icon = "󰖪"
                    root.value = ""
                    return
                }

                let parts = line.split(":")

                let type = parts[0]
                let name = parts[1]

                if (type === "wifi" || type === "802-11-wireless") {
                    root.icon = "󰖩"
                    root.value = name
                }
                else if (type === "ethernet") {
                    root.icon = "󰈀"
                    root.value = ""
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true

        onTriggered: network.running = true
    }

    Component.onCompleted: network.running = true
}

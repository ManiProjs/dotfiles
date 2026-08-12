pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string cpu: "0"
    property string memory: "0"
    property string temperature: "0"
    Process {
        id: stats

        command: [
            "bash",
            "-c",
            "echo CPU=$(top -bn1 | awk '/Cpu\\(s\\)/ {print int($2+$4)}'); echo MEM=$(free | awk '/Mem:/ {printf \"%d\", ($3/$2)*100}'); echo TEMP=$(sensors 2>/dev/null | awk '/Package id 0:/ {print int($4)}' | tr -d '+°C')"
        ]

        stdout: SplitParser {
            onRead: line => {
                let data = line.split("=")

                if (data.length !== 2)
                    return

                    switch (data[0]) {
                        case "CPU":
                            root.cpu = data[1]
                            break

                        case "MEM":
                            root.memory = data[1]
                            break

                        case "TEMP":
                            root.temperature = data[1]
                            break
                    }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true

        onTriggered: stats.running = true
    }

    Component.onCompleted: stats.running = true
}

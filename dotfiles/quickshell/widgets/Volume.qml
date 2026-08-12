import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"
import "../popups"

Label {
    id: root

    icon: "󰕾"
    value: "--%"

    function updateVolume() {
        volumeQuery.running = true
    }

    Process {
        id: volumeQuery

        command: [
            "bash",
            "-c",
            "pactl get-sink-volume @DEFAULT_SINK@ | grep -o '[0-9]*%' | head -1"
        ]

        stdout: SplitParser {
            onRead: data => {
                let v = parseInt(data.trim())

                if (!isNaN(v))
                    root.value = Math.min(100, Math.max(0, v)) + "%"
            }
        }
    }


    Process {
        id: volumeEvents

        command: [
            "pactl",
            "subscribe"
        ]

        stdout: SplitParser {
            onRead: data => {
                if (data.includes("sink"))
                    root.updateVolume()
            }
        }

        running: true
    }


    Process {
        id: volumeChange

        function change(amount) {
            command = [
                "pactl",
                "set-sink-volume",
                "@DEFAULT_SINK@",
                amount > 0
                ? "+" + amount + "%"
                : amount + "%"
            ]

            running = true

            root.updateVolume()
        }
    }


    MouseArea {
        anchors.fill: parent

        acceptedButtons: Qt.NoButton

        onWheel: wheel => {
            if (wheel.angleDelta.y > 0)
                volumeChange.change(5)
                else
                    volumeChange.change(-5)
        }
    }


    Component.onCompleted: {
        updateVolume()
    }
}

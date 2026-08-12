import QtQuick
import QtQuick.Controls
import "../theme"

Popup {
    id: root

    implicitHeight: 120

    Column {
        anchors.centerIn: parent

        spacing: 12

        Text {
            text: "󰕾 Volume"

            color: Theme.foreground

            font.family: Theme.fontFamily
            font.pixelSize: 16
        }

        Slider {
            width: 240

            from: 0
            to: 100

            value: 50

            onMoved: {
                Quickshell.execDetached([
                    "pactl",
                    "set-sink-volume",
                    "@DEFAULT_SINK@",
                    value + "%"
                ])
            }
        }
    }
}

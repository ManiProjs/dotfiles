import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import "../widgets"
import "../theme"

RowLayout {
    id: root

    property var barWindow
    property var controlCenter

    spacing: Theme.spacing

    Clock {}

    Cpu {}

    Memory {}

    Network {}

    Volume {}

    // Uncomment this line to show battery indicator in  the bar
    // Battery {}

    Media {}

    Tray {
        barWindow: root.barWindow
    }

    Text {
        text: "󰍜"

        color: Theme.foreground

        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 20

        MouseArea {
            anchors.fill: parent

            cursorShape: Qt.PointingHandCursor

            onClicked: {
                controlCenter.toggle()
            }
        }
    }
}

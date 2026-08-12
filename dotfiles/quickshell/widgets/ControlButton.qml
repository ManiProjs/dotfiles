import QtQuick
import Quickshell

Text {
    id: root

    text: "󰐥"

    color: "#cbd5e1"

    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 18

    signal clicked()

    MouseArea {
        anchors.fill: parent

        onClicked:
        root.clicked()
    }
}

import QtQuick
import Quickshell

PanelWindow {
    id: root

    property bool opened: false

    visible: opened

    color: "transparent"

    anchors {
        top: true
        right: true
    }

    implicitWidth: 320
    implicitHeight: 200

    Rectangle {
        anchors.fill: parent

        radius: 16

        color: "#141419"
        border.color: "#33ffffff"
        border.width: 1
    }
}

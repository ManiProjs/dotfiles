import QtQuick
import "../theme"

Rectangle {
    id: root

    property string icon: ""
    property string title: ""
    property bool enabled: false

    width: 160
    height: 90

    radius: 18

    color: enabled
    ? "#2563eb"
    : "#1e293b"


    Column {
        anchors.centerIn: parent

        spacing: 6


        Text {
            text: root.icon

            color: "white"

            font.family: Theme.fontFamily
            font.pixelSize: 24

            horizontalAlignment: Text.AlignHCenter
        }


        Text {
            text: root.title

            color: "white"

            font.family: Theme.fontFamily
            font.pixelSize: 13
        }
    }


    MouseArea {
        anchors.fill: parent

        onClicked: {
            root.enabled = !root.enabled
        }
    }


    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }
}

import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../theme"

Rectangle {
    id: root

    required property int workspaceId

    readonly property var workspace: {
        const values = Hyprland.workspaces.values
        for (let i = 0; i < values.length; ++i) {
            if (values[i].id === workspaceId)
                return values[i]
        }
        return null
    }

    readonly property bool focused: workspace && workspace.focused

    width: 30
    height: 24

    radius: 10

    color: mouse.containsMouse
    ? Theme.workspaceHover
    : (focused ? Theme.workspaceActive : "transparent")

    border.width: focused ? 0 : 1
    border.color: "#33ffffff"

    Behavior on color {
        ColorAnimation {
            duration: 120
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 120
        }
    }

    scale: mouse.containsMouse ? 1.04 : 1.0

    Text {
        anchors.centerIn: parent

        text: workspaceId

        color: focused
        ? "#ffffff"
        : Theme.inactive

        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: focused
    }

    Rectangle {

        visible: focused

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        height: 2

        radius: 1

        color: Theme.accent
    }

    MouseArea {
        id: mouse

        anchors.fill: parent

        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        onClicked: {
            Hyprland.dispatch(
                'hl.dsp.focus({ workspace = "' + workspaceId + '" })'
            )
        }
    }
}

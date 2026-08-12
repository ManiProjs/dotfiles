import QtQuick
import QtQuick.Layouts
import "../theme"

RowLayout {
    spacing: 8

    Text {
        text: ""

        color: Theme.foreground

        font.family: Theme.fontFamily
        font.pixelSize: 17
    }

    Repeater {
        model: 10

        delegate: WorkspaceButton {
            required property int index

            workspaceId: index + 1
        }
    }
}

import QtQuick
import QtQuick.Layouts

import "../theme"

RowLayout {
    id: root

    required property string icon
    required property string value

    spacing: 5

    Text {
        text: root.icon

        color: Theme.secondary

        font.family: Theme.fontFamily
        font.pixelSize: Theme.iconSize
    }

    Text {
        text: root.value

        color: Theme.secondary

        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}


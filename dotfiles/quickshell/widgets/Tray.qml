import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.SystemTray

RowLayout {
    id: root

    property var barWindow

    spacing: 8

    Repeater {
        model: SystemTray.items

        delegate: Item {
            required property var modelData

            width: 18
            height: 18

            QsMenuAnchor {
                id: menuAnchor

                menu: modelData.menu

                anchor.window: root.barWindow
                anchor.item: icon
                anchor.gravity: Edges.Bottom
            }

            Image {
                id: icon

                anchors.fill: parent

                source: modelData.icon

                fillMode: Image.PreserveAspectFit
            }

            MouseArea {
                anchors.fill: parent

                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        modelData.activate()
                    }

                    if (mouse.button === Qt.RightButton) {
                        if (modelData.menu)
                            menuAnchor.open()
                    }
                }
            }
        }
    }
}

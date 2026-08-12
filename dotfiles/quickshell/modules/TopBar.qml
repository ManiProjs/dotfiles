import QtQuick
import Quickshell

import "../theme"
import "../widgets"
import "../popups"

PanelWindow {
    id: barWindow

    property var controlCenter

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 42

    color: "transparent"
    Rectangle {
        anchors {
            fill: parent
            leftMargin: 15
            rightMargin: 15
            topMargin: 5
        }

        radius: 16

        color: Qt.rgba(20 / 255, 20 / 255, 25 / 255, 0.92)

        Item {
            anchors.fill: parent

            LeftSection {
                anchors {
                    left: parent.left
                    leftMargin: 12
                    verticalCenter: parent.verticalCenter
                }
            }

            CenterSection {
                anchors.centerIn: parent
            }

            RightSection {
                anchors {
                    right: parent.right
                    rightMargin: 12
                    verticalCenter: parent.verticalCenter
                }

                barWindow: barWindow
                controlCenter: barWindow.controlCenter
            }
        }
    }
}

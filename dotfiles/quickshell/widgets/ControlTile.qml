import QtQuick
import "../theme"

Rectangle {

    property string icon
    property string title
    property string value

    signal clicked()


    width: 160
    height: 90

    radius: 18

    color: "#1e293b"


    Column {

        anchors.centerIn: parent

        spacing: 5


        Text {
            text: icon

            color: "white"

            font.family: Theme.fontFamily
            font.pixelSize: 24
        }


        Text {
            text: title

            color: "white"

            font.family: Theme.fontFamily
        }


        Text {
            text: value

            color: "#94a3b8"

            font.family: Theme.fontFamily
        }
    }
}

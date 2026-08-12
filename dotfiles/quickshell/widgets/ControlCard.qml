import QtQuick
import "../theme"

Rectangle {

    property string icon
    property string title
    property string value


    width: parent.width
    height: 60

    radius: 14

    color: "#1e293b"


    Row {
        anchors.fill: parent

        anchors.margins: 14

        spacing: 12


        Text {
            text: icon

            color: "white"

            font.family: Theme.fontFamily
            font.pixelSize: 22
        }


        Column {

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
}

import QtQuick
import "../theme"

Text {
    id: root

    color: Theme.secondary

    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize

    function updateClock() {
        let now = new Date()
        text = Qt.formatDateTime(now, "ddd HH:mm")
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: root.updateClock()
    }

    Component.onCompleted: updateClock()
}

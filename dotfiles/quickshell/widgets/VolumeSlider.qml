import QtQuick
import QtQuick.Controls
import "../services"

Slider {
    id: root

    from: 0
    to: 100

    value: Audio.volume


    onMoved: {
        Audio.setVolume(Math.round(value))
    }


    Connections {
        target: Audio

        function onVolumeChanged() {
            root.value = Audio.volume
        }
    }
}

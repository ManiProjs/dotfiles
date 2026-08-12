import QtQuick
import Quickshell.Services.Mpris
import "../theme"

Label {
    id: root

    icon: "󰝚"
    value: "No media"

    readonly property var player: Mpris.players.values.length > 0
    ? Mpris.players.values[0]
    : null

    Connections {
        target: root.player

        function onTrackChanged() {
            root.update()
        }

        function onPlaybackStateChanged() {
            root.update()
        }
    }

    function update() {
        if (!player || !player.track) {
            value = "No media"
            return
        }

        let artist = player.track.artist || ""
        let title = player.track.title || ""

        if (artist.length > 0)
            value = artist + " - " + title
            else
                value = title
    }

    Component.onCompleted: update()
}

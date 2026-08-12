pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property int volume: 0
    property bool muted: false


    function update() {
        volumeProcess.running = true
        muteProcess.running = true
    }


    Process {
        id: volumeProcess

        command: [
            "bash",
            "-c",
            "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}'"
        ]

        stdout: SplitParser {
            onRead: data => {
                let v = parseInt(data)

                if (!isNaN(v))
                    root.volume = Math.min(100, v)
            }
        }
    }


    Process {
        id: muteProcess

        command: [
            "bash",
            "-c",
            "wpctl get-volume @DEFAULT_AUDIO_SINK@"
        ]

        stdout: SplitParser {
            onRead: data => {
                root.muted = data.includes("MUTED")
            }
        }
    }


    Process {
        id: events

        command: [
            "bash",
            "-c",
            "pactl subscribe"
        ]

        stdout: SplitParser {
            onRead: data => {
                if (data.includes("sink"))
                    root.update()
            }
        }

        running: true
    }


    function setVolume(value) {
        Quickshell.execDetached([
            "wpctl",
            "set-volume",
            "@DEFAULT_AUDIO_SINK@",
            value + "%"
        ])

        update()
    }


    function toggleMute() {
        Quickshell.execDetached([
            "wpctl",
            "set-mute",
            "@DEFAULT_AUDIO_SINK@",
            "toggle"
        ])

        update()
    }


    Component.onCompleted: update()
}

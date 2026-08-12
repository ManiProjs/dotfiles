import QtQuick
import Quickshell.Services.UPower
import "../theme"

Label {
    id: root

    icon: ""
    value: "--%"

    readonly property var battery: UPower.displayDevice

    Connections {
        target: battery

        function onPercentageChanged() {
            root.update()
        }

        function onStateChanged() {
            root.update()
        }
    }

    function update() {
        if (!battery)
            return

            value = Math.round(battery.percentage * 100) + "%"

            if (battery.state === UPowerDeviceState.Charging) {
                icon = "󰂄"
            } else if (battery.percentage <= 0.15) {
                icon = "󰁺"
            } else if (battery.percentage <= 0.30) {
                icon = "󰁻"
            } else {
                icon = ""
            }
    }

    Component.onCompleted: update()
}

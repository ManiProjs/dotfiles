import QtQuick
import Quickshell
import Quickshell.Io

PanelWindow {
    id: controlCenter

    property bool opened: false
    property bool powerMenuOpen: false
    property bool confirmPowerOpen: false
    property string pendingPowerAction: ""
    property bool powerMenuAnimating: false

    property real volume: 0.0
    property real brightness: 0.0
    property bool wifiEnabled: false
    property bool bluetoothEnabled: false

    property bool nightLightEnabled: false

    property bool volumeUpdating: false

    visible: opened

    anchors {
        top: true
        right: true
    }

    implicitWidth: 360
    implicitHeight: 500

    color: "transparent"

    // ============================================================
    // OPEN / CLOSE
    // ============================================================

    function toggle(): void {
        if (visible)
            close()
        else
            open()
    }

    function open(): void {
        visible = true
        powerMenuOpen = false
        confirmPowerOpen = false

        updateNetworkState()
        updateBluetoothState()
        updateVolume()
        updateBrightness()
    }

    function close(): void {
        visible = false
        powerMenuOpen = false
        confirmPowerOpen = false
    }

    // ============================================================
    // POWER MENU
    // ============================================================

    function openPowerMenu(): void {
        powerMenuAnimating = true

        powerMenuOpen = true
        confirmPowerOpen = false

        Qt.callLater(() => {
            powerMenuAnimating = false
        })
    }

    function closePowerMenu(): void {
        powerMenuOpen = false
        confirmPowerOpen = false
    }

    function requestPowerAction(action): void {
        pendingPowerAction = action
        confirmPowerOpen = true
    }

    function cancelPowerAction(): void {
        pendingPowerAction = ""
        confirmPowerOpen = false
    }

    function executePowerAction(): void {
        if (pendingPowerAction === "shutdown") {
            Quickshell.execDetached([
                "systemctl",
                "poweroff"
            ])
        } else if (pendingPowerAction === "reboot") {
            Quickshell.execDetached([
                "systemctl",
                "reboot"
            ])
        }

        cancelPowerAction()
    }

    // ============================================================
    // NETWORKMANAGER
    // ============================================================

    Process {
        id: wifiStateProcess

        command: [
            "nmcli",
            "radio",
            "wifi"
        ]

        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const result = text.trim().toLowerCase()

                controlCenter.wifiEnabled =
                result.includes("enabled")
            }
        }
    }

    Process {
        id: wifiToggleProcess

        running: false
    }

    function updateNetworkState(): void {
        if (!wifiStateProcess.running)
            wifiStateProcess.running = true
    }

    function toggleWifi(): void {
        if (wifiToggleProcess.running)
            return

            wifiToggleProcess.command = [
                "nmcli",
                "radio",
                "wifi",
                controlCenter.wifiEnabled
                ? "off"
                : "on"
            ]

            wifiToggleProcess.running = true

            wifiEnabled = !wifiEnabled
    }

    // ============================================================
    // BLUETOOTH
    // ============================================================

    Process {
        id: bluetoothStateProcess

        command: [
            "bluetoothctl",
            "show"
        ]

        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const output =
                text.toLowerCase()

                controlCenter.bluetoothEnabled =
                output.includes(
                    "powered: yes"
                )
            }
        }
    }

    Process {
        id: bluetoothToggleProcess

        running: false
    }

    function updateBluetoothState(): void {
        if (!bluetoothStateProcess.running)
            bluetoothStateProcess.running = true
    }

    function toggleBluetooth(): void {
        if (bluetoothToggleProcess.running)
            return

            bluetoothToggleProcess.command = [
                "bluetoothctl",
                "power",
                controlCenter.bluetoothEnabled
                ? "off"
                : "on"
            ]

            bluetoothToggleProcess.running = true

            bluetoothEnabled = !bluetoothEnabled
    }

    // ============================================================
    // PIPEWIRE / WPCTL
    // ============================================================

    Process {
        id: volumeProcess

        command: [
            "wpctl",
            "get-volume",
            "@DEFAULT_AUDIO_SINK@"
        ]

        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const output = text.trim()

                const match = output.match(
                    /Volume:\s*([0-9.]+)/
                )

                if (match && match[1]) {
                    let value = Number(match[1])

                    if (!isNaN(value)) {
                        controlCenter.volumeUpdating = true

                        controlCenter.volume =
                        Math.max(
                            0,
                            Math.min(1, value)
                        )

                        Qt.callLater(() => {
                            controlCenter.volumeUpdating = false
                        })
                    }
                }
            }
        }
    }

    Process {
        id: volumeSetProcess

        running: false
    }

    function updateVolume(): void {
        if (!volumeProcess.running)
            volumeProcess.running = true
    }

    function setVolume(value): void {
        value = Math.max(
            0,
            Math.min(1, value)
        )

        volume = value

        volumeSetProcess.command = [
            "wpctl",
            "set-volume",
            "@DEFAULT_AUDIO_SINK@",
            value.toFixed(2) + "%"
        ]

        volumeSetProcess.running = true
    }

    // ============================================================
    // BRIGHTNESSCTL
    // ============================================================

    Process {
        id: brightnessProcess

        command: [
            "brightnessctl",
            "-m"
        ]

        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const output = text.trim()

                /*
                 * brightnessctl -m output is generally:
                 *
                 * device,class,current,max,percentage
                 */

                const parts =
                output.split(",")

                if (parts.length >= 5) {
                    const current = Number(parts[2])
                    const max = Number(part[3].replace("%", ""))

                    if (!isNaN(current) && !isNaN(max) && max > 0) {
                        controlCenter.brightness = Math.max(0, Math.min(1, current / max))
                    }
                }
            }
        }
    }

    Process {
        id: brightnessSetProcess

        running: false
    }

    function updateBrightness(): void {
        if (!brightnessProcess.running)
            brightnessProcess.running = true
    }

    function setBrightness(value): void {
        value = Math.max(
            0,
            Math.min(1, value)
        )

        brightness = value

        brightnessSetProcess.command = [
            "brightnessctl",
            "set",
            Math.round(value * 100) + "%"
        ]

        brightnessSetProcess.running = true
    }

    // ============================================================
    // POWER MENU
    // ============================================================

    Rectangle {
        id: background

        anchors.fill: parent

        radius: 16

        color: Qt.rgba(
            20 / 255,
            20 / 255,
            25 / 255,
            0.92
        )

        border.width: 1

        border.color: Qt.rgba(
            255 / 255,
            255 / 255,
            255 / 255,
            0.06
        )

        // ========================================================
        // MAIN CONTENT
        // ========================================================

        Column {
            id: mainColumn

            anchors {
                fill: parent
                margins: 18
            }

            spacing: 14

            // ====================================================
            // HEADER
            // ====================================================

            Row {
                width: parent.width
                height: 30

                Text {
                    text:
                    controlCenter.powerMenuOpen
                    ? "Power Menu"
                    : "Control Center"

                    color: "#ffffff"

                    font.pixelSize: 18
                    font.bold: true

                    anchors.verticalCenter:
                    parent.verticalCenter
                }

                Item {
                    width:
                    parent.width - 130

                    height: 1
                }

                Text {
                    text: "×"

                    color: "#888890"

                    font.pixelSize: 22

                    anchors.verticalCenter:
                    parent.verticalCenter

                    MouseArea {
                        anchors.fill: parent

                        cursorShape:
                        Qt.PointingHandCursor

                        onClicked: {
                            controlCenter.close()
                        }
                    }
                }
            }

            // ====================================================
            // POWER MENU
            //
            // IMPORTANT:
            // This is directly inside the main Column.
            // No Loader.
            // No fixed 300px Item.
            // No vertical centering.
            // ====================================================

            Column {
                id: powerMenu

                width: parent.width

                spacing: 8

                x: controlCenter.powerMenuOpen
                    ? 0
                    : parent.width

                opacity:
                    controlCenter.powerMenuOpen
                        ? 1
                        : 0

                Behavior on x {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 180
                    }
                }

                visible:
                controlCenter.powerMenuOpen &&
                !controlCenter.confirmPowerOpen

                PowerButton {
                    width: parent.width
                    height: 44

                    icon: "󰤄"
                    text: "Lock"

                    command: [
                        "hyprlock"
                    ]
                }

                PowerButton {
                    width: parent.width
                    height: 44

                    icon: "󰗼"
                    text: "Logout"

                    command: [
                        "loginctl",
                        "terminate-user",
                        Quickshell.env("USER")
                    ]
                }

                PowerButton {
                    width: parent.width
                    height: 44

                    icon: "󰜉"
                    text: "Shutdown"

                    onClicked: {
                        controlCenter.requestPowerAction(
                            "shutdown"
                        )
                    }
                }

                PowerButton {
                    width: parent.width
                    height: 44

                    icon: "󰜉"
                    text: "Reboot"

                    onClicked: {
                        controlCenter.requestPowerAction(
                            "reboot"
                        )
                    }
                }

                PowerButton {
                    width: parent.width
                    height: 44

                    icon: "󰅙"
                    text: "Back"

                    onClicked: {
                        controlCenter.closePowerMenu()
                    }
                }
            }

            // ====================================================
            // CONFIRMATION
            // ====================================================

            Column {
                id: confirmation

                width: parent.width

                spacing: 14

                visible:
                controlCenter.confirmPowerOpen

                Text {
                    width: parent.width

                    text:
                    controlCenter.pendingPowerAction ===
                    "shutdown"
                    ? "Shut down your computer?"
                    : "Restart your computer?"

                    color: "#ffffff"

                    font.pixelSize: 16
                    font.bold: true

                    horizontalAlignment:
                    Text.AlignHCenter
                }

                Text {
                    width: parent.width

                    text:
                    controlCenter.pendingPowerAction ===
                    "shutdown"
                    ? "All running applications will be closed."
                    : "Your computer will restart."

                    color: "#888890"

                    font.pixelSize: 11

                    horizontalAlignment:
                    Text.AlignHCenter

                    wrapMode:
                    Text.WordWrap
                }

                Row {
                    width: parent.width

                    height: 44

                    spacing: 10

                    ActionButton {
                        width:
                        (parent.width - 10) / 2

                        height: parent.height

                        icon: "󰅖"
                        text: "Cancel"

                        onClicked: {
                            controlCenter.cancelPowerAction()
                        }
                    }

                    ActionButton {
                        width:
                        (parent.width - 10) / 2

                        height: parent.height

                        icon:
                        controlCenter.pendingPowerAction ===
                        "shutdown"
                        ? "󰐥"
                        : "󰜉"

                        text: "Confirm"

                        onClicked: {
                            controlCenter.executePowerAction()
                        }
                    }
                }
            }

            // ====================================================
            // NORMAL CONTROL CENTER
            // ====================================================

            Column {
                id: normalContent

                width: parent.width

                spacing: 14

                x:
                    controlCenter.powerMenuOpen
                    ? -parent.width
                    : 0

                opacity:
                    controlCenter.powerMenuOpen
                    ? 0
                    : 1

                Behavior on x {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 180
                    }
                }

                // =================================================
                // QUICK TOGGLES
                // =================================================

                Row {
                    width: parent.width

                    height: 90

                    spacing: 10

                    ToggleCard {
                        width:
                        (parent.width - 10) / 2

                        height: parent.height

                        icon: "󰤨"
                        title: "Wi-Fi"

                        subtitle:
                        controlCenter.wifiEnabled
                        ? "On"
                        : "Off"

                        active:
                        controlCenter.wifiEnabled

                        onClicked: {
                            controlCenter.toggleWifi()
                        }
                    }

                    ToggleCard {
                        width:
                        (parent.width - 10) / 2

                        height: parent.height

                        icon: "󰂯"
                        title: "Bluetooth"

                        subtitle:
                        controlCenter.bluetoothEnabled
                        ? "On"
                        : "Off"

                        active:
                        controlCenter.bluetoothEnabled

                        onClicked: {
                            controlCenter.toggleBluetooth()
                        }
                    }
                }

                // =================================================
                // VOLUME
                // =================================================

                SliderCard {
                    width: parent.width

                    icon: "󰕾"
                    title: "Volume"

                    value:
                    controlCenter.volume

                    onValueChanged: {
                        if (!controlCenter.visible)
                            return

                        if (controlCenter.volumeUpdating)
                            return

                        controlCenter.setVolume(value)
                    }
                }

                // =================================================
                // BRIGHTNESS
                // =================================================

                SliderCard {
                    width: parent.width

                    icon: "󰃠"
                    title: "Brightness"

                    value:
                    controlCenter.brightness

                    onValueChanged: {
                        if (!controlCenter.visible)
                            return

                            controlCenter.setBrightness(
                                value
                            )
                    }
                }

                // =================================================
                // SECONDARY TOGGLES
                // =================================================

                Row {
                    width: parent.width

                    height: 80

                    spacing: 10

                    ToggleCard {
                        width:
                        (parent.width - 10) / 2

                        height: parent.height

                        icon: "󰖔"
                        title: "Night Light"

                        subtitle:
                        controlCenter.nightLightEnabled
                        ? "On"
                        : "Off"

                        active:
                        controlCenter.nightLightEnabled

                        onClicked: {
                            controlCenter.nightLightEnabled =
                            !controlCenter.nightLightEnabled
                        }
                    }

                    ToggleCard {
                        width:
                        (parent.width - 10) / 2

                        height: parent.height

                        icon: "󰂄"
                        title: "Battery"

                        subtitle: "System"

                        active: true

                        onClicked: {
                            // Battery is informational.
                        }
                    }
                }

                // =================================================
                // BOTTOM ACTIONS
                // =================================================

                Row {
                    width: parent.width

                    height: 42

                    spacing: 10

                    ActionButton {
                        width:
                        (parent.width - 10) / 2

                        height: parent.height

                        icon: "󰒓"
                        text: "Settings"

                        onClicked: {
                            Quickshell.execDetached([
                                "systemsettings"
                            ])
                        }
                    }

                    ActionButton {
                        width:
                        (parent.width - 10) / 2

                        height: parent.height

                        icon: "󰐥"
                        text: "Power"

                        onClicked: {
                            controlCenter.openPowerMenu()
                        }
                    }
                }
            }
        }

        // ========================================================
        // TOGGLE CARD
        // ========================================================

        component ToggleCard: Rectangle {
            property string icon
            property string title
            property string subtitle
            property bool active

            signal clicked()

            radius: 14

            color:
            active
            ? Qt.rgba(
                255 / 255,
                255 / 255,
                255 / 255,
                0.12
            )
            : Qt.rgba(
                255 / 255,
                255 / 255,
                255 / 255,
                0.055
            )

            border.width: 1

            border.color:
            active
            ? Qt.rgba(
                255 / 255,
                255 / 255,
                255 / 255,
                0.10
            )
            : Qt.rgba(
                255 / 255,
                255 / 255,
                255 / 255,
                0.04
            )

            Column {
                anchors {
                    left: parent.left
                    verticalCenter:
                    parent.verticalCenter

                    leftMargin: 14
                }

                spacing: 4

                Text {
                    text: parent.parent.icon

                    color:
                    parent.parent.active
                    ? "#ffffff"
                    : "#8b8b94"

                    font.family:
                    "JetBrainsMono Nerd Font"

                    font.pixelSize: 22
                }

                Text {
                    text: parent.parent.title

                    color: "#ffffff"

                    font.pixelSize: 13
                    font.bold: true
                }

                Text {
                    text: parent.parent.subtitle

                    color: "#888890"

                    font.pixelSize: 11
                }
            }

            MouseArea {
                anchors.fill: parent

                cursorShape:
                Qt.PointingHandCursor

                onClicked: {
                    parent.clicked()
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }

        // ========================================================
        // SLIDER CARD
        // ========================================================

        component SliderCard: Rectangle {
            property string icon
            property string title
            property real value

            radius: 14

            height: 64

            color:
            Qt.rgba(
                255 / 255,
                255 / 255,
                255 / 255,
                0.055
            )

            border.width: 1

            border.color:
            Qt.rgba(
                255 / 255,
                255 / 255,
                255 / 255,
                0.04
            )

            Row {
                anchors {
                    fill: parent

                    leftMargin: 14
                    rightMargin: 14
                }

                spacing: 12

                Text {
                    width: 28

                    text:
                    parent.parent.icon

                    color: "#ffffff"

                    font.family:
                    "JetBrainsMono Nerd Font"

                    font.pixelSize: 20

                    anchors.verticalCenter:
                    parent.verticalCenter
                }

                Column {
                    width:
                    parent.width - 40

                    anchors.verticalCenter:
                    parent.verticalCenter

                    spacing: 7

                    Row {
                        width: parent.width

                        Text {
                            text:
                            parent.parent.parent.title

                            color: "#ffffff"

                            font.pixelSize: 12
                            font.bold: true
                        }

                        Item {
                            width:
                            parent.width - 100

                            height: 1
                        }

                        Text {
                            text:
                            Math.round(
                                parent.parent.parent.value *
                                100
                            ) + "%"

                            color: "#888890"

                            font.pixelSize: 11
                        }
                    }

                    Rectangle {
                        id: sliderTrack

                        width: parent.width

                        height: 5

                        radius: 3

                        color:
                        Qt.rgba(
                            255 / 255,
                            255 / 255,
                            255 / 255,
                            0.10
                        )

                        Rectangle {
                            width:
                            parent.width *
                            parent.parent.parent.value

                            height: parent.height

                            radius: 3

                            color: "#ffffff"
                        }

                        MouseArea {
                            anchors.fill: parent

                            onPressed: {
                                parent.parent.parent.parent.value =
                                Math.max(
                                    0,
                                    Math.min(
                                        1,
                                        mouse.x /
                                        width
                                    )
                                )
                            }

                            onPositionChanged: {
                                if (pressed) {
                                    parent.parent.parent.parent.value =
                                    Math.max(
                                        0,
                                        Math.min(
                                            1,
                                            mouse.x /
                                            width
                                        )
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }

        // ========================================================
        // ACTION BUTTON
        // ========================================================

        component ActionButton: Rectangle {
            property string icon
            property string text

            signal clicked()

            radius: 12

            color:
            Qt.rgba(
                255 / 255,
                255 / 255,
                255 / 255,
                0.055
            )

            border.width: 1

            border.color:
            Qt.rgba(
                255 / 255,
                255 / 255,
                255 / 255,
                0.04
            )

            Row {
                anchors.centerIn: parent

                spacing: 8

                Text {
                    text:
                    parent.parent.icon

                    color: "#ffffff"

                    font.family:
                    "JetBrainsMono Nerd Font"

                    font.pixelSize: 17

                    anchors.verticalCenter:
                    parent.verticalCenter
                }

                Text {
                    text:
                    parent.parent.text

                    color: "#ffffff"

                    font.pixelSize: 12

                    anchors.verticalCenter:
                    parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent

                cursorShape:
                Qt.PointingHandCursor

                onClicked: {
                    parent.clicked()
                }
            }
        }

        // ========================================================
        // POWER BUTTON
        // ========================================================

        component PowerButton: Rectangle {
            property string icon
            property string text
            property var command: []

            signal clicked()

            width: 324
            height: 44

            radius: 12

            color:
            mouseArea.containsMouse
            ? Qt.rgba(
                255 / 255,
                255 / 255,
                255 / 255,
                0.10
            )
            : Qt.rgba(
                255 / 255,
                255 / 255,
                255 / 255,
                0.055
            )

            border.width: 1

            border.color:
            Qt.rgba(
                255 / 255,
                255 / 255,
                255 / 255,
                0.04
            )

            Row {
                anchors {
                    left: parent.left
                    leftMargin: 14

                    verticalCenter:
                    parent.verticalCenter
                }

                spacing: 12

                Text {
                    text:
                    parent.parent.icon

                    width: 24

                    color: "#ffffff"

                    font.family:
                    "JetBrainsMono Nerd Font"

                    font.pixelSize: 19

                    horizontalAlignment:
                    Text.AlignHCenter
                }

                Text {
                    text:
                    parent.parent.text

                    color: "#ffffff"

                    font.pixelSize: 13

                    anchors.verticalCenter:
                    parent.verticalCenter
                }
            }

            MouseArea {
                id: mouseArea

                anchors.fill: parent

                hoverEnabled: true

                cursorShape:
                Qt.PointingHandCursor

                onClicked: {
                    if (
                        parent.command &&
                        parent.command.length > 0
                    ) {
                        Quickshell.execDetached(
                            parent.command
                        )
                    }

                    parent.clicked()
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }
        }
    }

    // ============================================================
    // PERIODIC STATE UPDATE
    // ============================================================

    Timer {
        interval: 3000

        repeat: true

        running: controlCenter.visible

        onTriggered: {
            controlCenter.updateNetworkState()
            controlCenter.updateBluetoothState()
            controlCenter.updateVolume()
            controlCenter.updateBrightness()
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    // ============================================================
    // STATE
    // ============================================================

    property bool opened: false
    property string searchQuery: ""
    property int selectedIndex: 0
    property var apps: []

    // ============================================================
    // WINDOW
    // ============================================================

    visible: opened

    focusable: opened

    WlrLayershell.layer: WlrLayer.Overlay

    WlrLayershell.keyboardFocus:
    opened
    ? WlrKeyboardFocus.Exclusive
    : WlrKeyboardFocus.None

    implicitWidth: 780
    implicitHeight: 600

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    // ============================================================
    // IPC
    // ============================================================

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.toggle()
        }

        function open(): void {
            root.open()
        }

        function close(): void {
            root.close()
        }

        function refresh(): void {
            root.refreshApps()
        }
    }

    // ============================================================
    // APP CACHE
    // ============================================================

    FileView {
        id: appsFile

        path: Qt.resolvedUrl("apps.json")
        blockLoading: true

        onLoaded: {
            root.loadApps()
        }
    }

    // ============================================================
    // CHECK apps.json
    // ============================================================

    Process {
        id: fileCheck

        command: [
            "test",
            "-f",
            Qt.resolvedUrl("apps.json")
            .toString()
            .replace("file://", "")
        ]

        running: false

        onExited: function(exitCode, exitStatus) {
            if (exitCode !== 0) {
                console.log(
                    "apps.json does not exist"
                )

                root.refreshApps()
            } else {
                console.log(
                    "apps.json exists"
                )

                appsFile.reload()
            }
        }
    }

    // ============================================================
    // APPLICATION SCANNER
    // ============================================================

    Process {
        id: scanner

        command: [
            "python3",
            Qt.resolvedUrl("scan_apps.py")
            .toString()
            .replace("file://", "")
        ]

        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    console.log(
                        "Scanner:",
                        text.trim()
                    )
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    console.error(
                        "Scanner:",
                        text.trim()
                    )
                }
            }
        }

        onExited: function(exitCode, exitStatus) {
            if (exitCode === 0) {
                console.log(
                    "Application scan completed"
                )
            } else {
                console.error(
                    "Application scanner failed:",
                    exitCode
                )
            }

            appsFile.reload()
        }
    }

    // ============================================================
    // AUTOMATIC APP DATABASE UPDATE
    //
    // The scanner is periodically executed so newly installed
    // or removed .desktop applications are detected automatically.
    // ============================================================

    Timer {
        id: appRefreshTimer

        interval: 5000

        repeat: true

        running: true

        onTriggered: {
            root.refreshApps()
        }
    }

    // ============================================================
    // REFRESH APPLICATIONS
    // ============================================================

    function refreshApps() {
        if (scanner.running)
            return

            scanner.running = true
    }

    // ============================================================
    // APP MODEL
    // ============================================================

    ListModel {
        id: appModel
    }

    // ============================================================
    // FUZZY SEARCH
    // ============================================================

    function fuzzyScore(query, text) {
        query = query.toLowerCase()
        text = text.toLowerCase()

        if (query.length === 0)
            return 0

            if (text === query)
                return 10000

                if (text.startsWith(query))
                    return 8000 - text.length

                    const exactIndex =
                    text.indexOf(query)

                    if (exactIndex >= 0) {
                        return 6000 -
                        exactIndex * 20 -
                        text.length
                    }

                    // --------------------------------------------------------
                    // Subsequence matching
                    //
                    // "firefox" -> "Firefox"
                    // "ffx"     -> "Firefox"
                    // "term"    -> "GNOME Terminal"
                    // --------------------------------------------------------

                    let queryIndex = 0
                    let textIndex = 0

                    let score = 0
                    let lastMatch = -1
                    let consecutive = 0

                    while (
                        queryIndex < query.length &&
                        textIndex < text.length
                    ) {
                        if (
                            query.charAt(queryIndex) ===
                            text.charAt(textIndex)
                        ) {
                            score += 100

                            if (
                                lastMatch >= 0 &&
                                textIndex === lastMatch + 1
                            ) {
                                consecutive++

                                score +=
                                consecutive * 50
                            } else {
                                consecutive = 0
                            }

                            lastMatch = textIndex
                            queryIndex++
                        }

                        textIndex++
                    }

                    if (queryIndex !== query.length)
                        return -1

                        // Prefer shorter matches.
                        score -= text.length * 2

                        // Prefer matches near the beginning.
                        score -= lastMatch * 3

                        return score
    }

    // ============================================================
    // SEARCH RESULT SCORE
    // ============================================================

    function appScore(app, query) {
        if (query.length === 0)
            return 0

            const name =
            (app.name || "").toLowerCase()

            const comment =
            (app.comment || "").toLowerCase()

            const nameScore =
            fuzzyScore(query, name)

            const commentScore =
            fuzzyScore(query, comment)

            // Application name is significantly more important
            // than description.
            if (
                nameScore < 0 &&
                commentScore < 0
            ) {
                return -1
            }

            return Math.max(
                nameScore,
                commentScore * 0.35
            )
    }

    // ============================================================
    // SEARCH
    // ============================================================

    function filterApps() {
        const query =
        searchQuery.trim().toLowerCase()

        const results = []

        for (const app of apps) {
            const score =
            appScore(app, query)

            if (
                query === "" ||
                score >= 0
            ) {
                results.push({
                    app: app,
                    score: score
                })
            }
        }

        // Highest score first.
        results.sort(function(a, b) {
            if (b.score !== a.score)
                return b.score - a.score

                return (
                    (a.app.name || "").toLowerCase()
                    .localeCompare(
                        (b.app.name || "").toLowerCase()
                    )
                )
        })

        appModel.clear()

        for (const result of results) {
            appModel.append(result.app)
        }

        selectedIndex = 0

        if (appModel.count > 0) {
            appList.currentIndex = 0
        } else {
            appList.currentIndex = -1
        }
    }

    // ============================================================
    // LOAD APPS
    // ============================================================

    function loadApps() {
        try {
            const text = appsFile.text()

            if (
                !text ||
                text.trim() === ""
            ) {
                console.warn(
                    "apps.json is empty"
                )

                return
            }

            const parsed =
            JSON.parse(text)

            if (!Array.isArray(parsed)) {
                console.error(
                    "apps.json must contain an array"
                )

                return
            }

            apps = parsed

            console.log(
                "Loaded",
                apps.length,
                "applications"
            )

            filterApps()
        } catch (error) {
            console.error(
                "Failed to parse apps.json:",
                error
            )
        }
    }

    // ============================================================
    // NAVIGATION
    // ============================================================

    function selectNext() {
        if (appModel.count === 0)
            return

            selectedIndex =
            (selectedIndex + 1) %
            appModel.count

            appList.currentIndex =
            selectedIndex

            appList.positionViewAtIndex(
                selectedIndex,
                ListView.Contain
            )
    }

    function selectPrevious() {
        if (appModel.count === 0)
            return

            selectedIndex =
            (selectedIndex - 1 +
            appModel.count) %
            appModel.count

            appList.currentIndex =
            selectedIndex

            appList.positionViewAtIndex(
                selectedIndex,
                ListView.Contain
            )
    }

    function selectFirst() {
        if (appModel.count === 0)
            return

            selectedIndex = 0
            appList.currentIndex = 0

            appList.positionViewAtIndex(
                0,
                ListView.Beginning
            )
    }

    function selectLast() {
        if (appModel.count === 0)
            return

            selectedIndex =
            appModel.count - 1

            appList.currentIndex =
            selectedIndex

            appList.positionViewAtIndex(
                selectedIndex,
                ListView.End
            )
    }

    function selectPageDown() {
        if (appModel.count === 0)
            return

            selectedIndex = Math.min(
                selectedIndex + 7,
                appModel.count - 1
            )

            appList.currentIndex =
            selectedIndex

            appList.positionViewAtIndex(
                selectedIndex,
                ListView.Contain
            )
    }

    function selectPageUp() {
        if (appModel.count === 0)
            return

            selectedIndex = Math.max(
                selectedIndex - 7,
                0
            )

            appList.currentIndex =
            selectedIndex

            appList.positionViewAtIndex(
                selectedIndex,
                ListView.Contain
            )
    }

    // ============================================================
    // LAUNCH
    // ============================================================

    Process {
        id: launchProcess
    }

    function launchSelected() {
        if (appModel.count === 0)
            return

            const app =
            appModel.get(selectedIndex)

            if (
                !app ||
                !app.exec
            ) {
                return
            }

            console.log(
                "Launching:",
                app.name
            )

            console.log(
                "Command:",
                app.exec
            )

            launchProcess.command = [
                "sh",
                "-c",
                app.exec
            ]

            launchProcess.running = true

            root.close()
    }

    // ============================================================
    // OPEN
    // ============================================================

    function open() {
        root.opened = true

        searchQuery = ""
        selectedIndex = 0

        searchField.text = ""

        filterApps()

        Qt.callLater(function() {
            searchField.forceActiveFocus()
        })
    }

    // ============================================================
    // CLOSE
    // ============================================================

    function close() {
        root.opened = false
    }

    // ============================================================
    // TOGGLE
    // ============================================================

    function toggle() {
        if (root.opened) {
            root.close()
        } else {
            root.open()
        }
    }

    // ============================================================
    // MAIN CONTENT
    // ============================================================

    Item {
        id: launcherContent

        anchors.fill: parent

        focus: root.opened

        // ========================================================
        // BACKDROP
        // ========================================================

        Rectangle {
            anchors.fill: parent

            color: "#55000000"

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    root.close()
                }
            }
        }

        // ========================================================
        // LAUNCHER CARD
        // ========================================================

        Rectangle {
            id: launcherCard

            anchors.centerIn: parent

            width: 700
            height: 520

            radius: 24

            color: "#191923"

            border.width: 1
            border.color: "#36364b"

            // ====================================================
            // CARD CONTENT
            // ====================================================

            ColumnLayout {
                anchors.fill: parent

                anchors.margins: 20

                spacing: 14

                // =================================================
                // HEADER
                // =================================================

                RowLayout {
                    Layout.fillWidth: true

                    spacing: 12

                    Rectangle {
                        width: 46
                        height: 46

                        radius: 14

                        color: "#29293d"

                        Text {
                            anchors.centerIn: parent

                            text: "⌕"

                            color: "#8f8fff"

                            font.pixelSize: 28
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true

                        spacing: 2

                        Text {
                            text: "Applications"

                            color: "#ffffff"

                            font {
                                pixelSize: 19
                                weight: Font.DemiBold
                            }
                        }

                        Text {
                            Layout.fillWidth: true

                            text:
                            root.searchQuery.length > 0
                            ? `Searching for "${root.searchQuery}"`
                            : "Find and launch an application"

                            color: "#77778c"

                            font.pixelSize: 11

                            elide:
                            Text.ElideRight
                        }
                    }

                    Rectangle {
                        width: 42
                        height: 30

                        radius: 8

                        color: "#29293b"

                        Text {
                            anchors.centerIn: parent

                            text: "Esc"

                            color: "#88889c"

                            font.pixelSize: 10
                        }
                    }
                }

                // =================================================
                // SEARCH BAR
                // =================================================

                Rectangle {
                    Layout.fillWidth: true

                    height: 54

                    radius: 15

                    color: "#232333"

                    border.width: 1

                    border.color:
                    searchField.activeFocus
                    ? "#7777ff"
                    : "#343448"

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 120
                        }
                    }

                    RowLayout {
                        anchors.fill: parent

                        anchors.leftMargin: 16
                        anchors.rightMargin: 12

                        spacing: 10

                        Text {
                            text: "⌕"

                            color: "#85859c"

                            font.pixelSize: 22
                        }

                        TextField {
                            id: searchField

                            Layout.fillWidth: true

                            background: null

                            placeholderText:
                            "Search applications..."

                            placeholderTextColor:
                            "#66667b"

                            color: "#ffffff"

                            font.pixelSize: 15

                            leftPadding: 0
                            rightPadding: 0

                            focus:
                            root.opened

                            onTextChanged: {
                                root.searchQuery =
                                text

                                root.filterApps()
                            }

                            // =====================================
                            // KEYBOARD
                            // =====================================

                            Keys.onPressed:
                            function(event) {

                                if (
                                    event.key ===
                                    Qt.Key_Down
                                ) {
                                    root.selectNext()

                                    event.accepted =
                                    true

                                    return
                                }

                                if (
                                    event.key ===
                                    Qt.Key_Up
                                ) {
                                    root.selectPrevious()

                                    event.accepted =
                                    true

                                    return
                                }

                                if (
                                    event.key ===
                                    Qt.Key_Return ||
                                    event.key ===
                                    Qt.Key_Enter
                                ) {
                                    root.launchSelected()

                                    event.accepted =
                                    true

                                    return
                                }

                                if (
                                    event.key ===
                                    Qt.Key_Escape
                                ) {
                                    root.close()

                                    event.accepted =
                                    true

                                    return
                                }

                                if (
                                    event.key ===
                                    Qt.Key_Home
                                ) {
                                    root.selectFirst()

                                    event.accepted =
                                    true

                                    return
                                }

                                if (
                                    event.key ===
                                    Qt.Key_End
                                ) {
                                    root.selectLast()

                                    event.accepted =
                                    true

                                    return
                                }

                                if (
                                    event.key ===
                                    Qt.Key_PageDown
                                ) {
                                    root.selectPageDown()

                                    event.accepted =
                                    true

                                    return
                                }

                                if (
                                    event.key ===
                                    Qt.Key_PageUp
                                ) {
                                    root.selectPageUp()

                                    event.accepted =
                                    true

                                    return
                                }

                                // Ctrl+R
                                if (
                                    event.key ===
                                    Qt.Key_R &&
                                    (
                                        event.modifiers &
                                        Qt.ControlModifier
                                    )
                                ) {
                                    root.refreshApps()

                                    event.accepted =
                                    true

                                    return
                                }
                            }
                        }
                    }
                }

                // =================================================
                // RESULTS
                // =================================================

                ListView {
                    id: appList

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    clip: true

                    spacing: 5

                    model: appModel

                    currentIndex:
                    root.selectedIndex

                    delegate: Rectangle {
                        id: delegateRoot

                        required property int index
                        required property string name
                        required property string comment
                        required property string exec
                        required property string icon

                        width:
                        ListView.view.width

                        height: 62

                        radius: 13

                        color:
                        index === root.selectedIndex
                        ? "#30304a"
                        : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                            }
                        }

                        // =========================================
                        // ICON
                        // =========================================

                        Rectangle {
                            id: iconContainer

                            anchors {
                                left: parent.left
                                leftMargin: 8
                                verticalCenter:
                                parent.verticalCenter
                            }

                            width: 46
                            height: 46

                            radius: 13

                            color:
                            index === root.selectedIndex
                            ? "#41415e"
                            : "#29293a"

                            Image {
                                id: iconImage

                                anchors.centerIn: parent

                                width: 36
                                height: 36

                                source:
                                delegateRoot.icon

                                fillMode:
                                Image.PreserveAspectFit

                                asynchronous: true

                                smooth: true

                                visible:
                                status === Image.Ready
                            }

                            Text {
                                anchors.centerIn: parent

                                visible:
                                !iconImage.visible

                                text:
                                delegateRoot.name.length > 0
                                ? delegateRoot.name
                                .charAt(0)
                                .toUpperCase()
                                : "?"

                                color: "#ffffff"

                                font {
                                    pixelSize: 17
                                    bold: true
                                }
                            }
                        }

                        // =========================================
                        // TEXT
                        // =========================================

                        Column {
                            anchors {
                                left:
                                iconContainer.right

                                leftMargin: 13

                                right: parent.right
                                rightMargin: 28

                                verticalCenter:
                                parent.verticalCenter
                            }

                            spacing: 3

                            Text {
                                width:
                                parent.width

                                text:
                                delegateRoot.name

                                color:
                                index ===
                                root.selectedIndex
                                ? "#ffffff"
                                : "#e4e4ea"

                                font {
                                    pixelSize: 14
                                    weight: Font.Medium
                                }

                                elide:
                                Text.ElideRight
                            }

                            Text {
                                width:
                                parent.width

                                text:
                                delegateRoot.comment

                                color: "#858599"

                                font.pixelSize: 11

                                elide:
                                Text.ElideRight

                                visible:
                                text.length > 0
                            }
                        }

                        // =========================================
                        // SELECTED INDICATOR
                        // =========================================

                        Rectangle {
                            anchors {
                                right: parent.right
                                rightMargin: 7
                                verticalCenter:
                                parent.verticalCenter
                            }

                            width: 3
                            height: 30

                            radius: 2

                            color: "#9090ff"

                            visible:
                            index === root.selectedIndex
                        }

                        // =========================================
                        // MOUSE
                        // =========================================

                        MouseArea {
                            anchors.fill: parent

                            hoverEnabled: true

                            onEntered: {
                                root.selectedIndex =
                                delegateRoot.index

                                appList.currentIndex =
                                delegateRoot.index
                            }

                            onClicked: {
                                root.selectedIndex =
                                delegateRoot.index

                                root.launchSelected()
                            }
                        }
                    }

                    // =================================================
                    // EMPTY RESULT
                    // =================================================

                    Text {
                        anchors.centerIn: parent

                        visible:
                        appModel.count === 0

                        text:
                        root.searchQuery.length > 0
                        ? "No applications found"
                        : "No applications available"

                        color: "#77778c"

                        font.pixelSize: 14
                    }

                    ScrollBar.vertical:
                    ScrollBar {
                        policy:
                        ScrollBar.AsNeeded
                    }

                    onCurrentIndexChanged: {
                        if (currentIndex >= 0) {
                            positionViewAtIndex(
                                currentIndex,
                                ListView.Contain
                            )
                        }
                    }
                }

                // =================================================
                // FOOTER
                // =================================================

                Rectangle {
                    Layout.fillWidth: true

                    height: 1

                    color: "#29293a"
                }

                RowLayout {
                    Layout.fillWidth: true

                    spacing: 14

                    Text {
                        text:
                        `${appModel.count} applications`

                        color: "#66667a"

                        font.pixelSize: 10
                    }

                    Text {
                        text:
                        root.searchQuery.length > 0
                        ? "Fuzzy search"
                        : "Ready"

                        color: "#66667a"

                        font.pixelSize: 10
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "↑ ↓  Navigate"

                        color: "#66667a"

                        font.pixelSize: 10
                    }

                    Text {
                        text: "↵  Launch"

                        color: "#66667a"

                        font.pixelSize: 10
                    }

                    Text {
                        text: "Esc  Close"

                        color: "#66667a"

                        font.pixelSize: 10
                    }
                }
            }
        }
    }

    // ============================================================
    // STARTUP
    // ============================================================

    Component.onCompleted: {
        fileCheck.running = true
    }
}

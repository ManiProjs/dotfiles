pragma Singleton

import QtQuick

QtObject {

    // ------------------------------------------------------------------
    // Typography
    // ------------------------------------------------------------------

    readonly property string fontFamily: "JetBrainsMono Nerd Font"

    readonly property int fontSize: 12
    readonly property int iconSize: 14

    readonly property int titleSize: 18
    readonly property int subtitleSize: 11
    readonly property int smallFontSize: 10

    // ------------------------------------------------------------------
    // Colors
    // ------------------------------------------------------------------

    readonly property color foreground: "#e5e7eb"
    readonly property color secondary: "#cbd5e1"
    readonly property color inactive: "#6b7280"

    // Primary surfaces

    readonly property color background: Qt.rgba(
        20 / 255,
        20 / 255,
        25 / 255,
        0.92
    )

    readonly property color surface: Qt.rgba(
        30 / 255,
        35 / 255,
        45 / 255,
        0.96
    )

    readonly property color surfaceHover: Qt.rgba(
        40 / 255,
        46 / 255,
        58 / 255,
        1.0
    )

    readonly property color surfacePressed: Qt.rgba(
        55 / 255,
        63 / 255,
        78 / 255,
        1.0
    )

    readonly property color outline: Qt.rgba(
        1.0,
        1.0,
        1.0,
        0.08
    )

    readonly property color outlineStrong: Qt.rgba(
        1.0,
        1.0,
        1.0,
        0.15
    )

    // Existing workspace colors

    readonly property color workspaceHover: "#141a22"
    readonly property color workspaceActive: "#1e293b"

    // Accent

    readonly property color accent: "#3b82f6"
    readonly property color accentHover: "#60a5fa"

    // Status colors

    readonly property color success: "#22c55e"
    readonly property color warning: "#f59e0b"
    readonly property color error: "#ef4444"

    // ------------------------------------------------------------------
    // Geometry
    // ------------------------------------------------------------------

    readonly property int barHeight: 32

    readonly property int radiusSmall: 10
    readonly property int radius: 16
    readonly property int radiusLarge: 22

    readonly property int workspaceRadius: 10

    readonly property int paddingSmall: 8
    readonly property int padding: 12
    readonly property int paddingLarge: 18

    readonly property int spacingSmall: 6
    readonly property int spacing: 10
    readonly property int spacingLarge: 16

    // Control Center

    readonly property int tileWidth: 165
    readonly property int tileHeight: 92

    readonly property int controlCenterWidth: 390
    readonly property int controlCenterHeight: 600

    // ------------------------------------------------------------------
    // Animation
    // ------------------------------------------------------------------

    readonly property int animationFast: 120
    readonly property int animationNormal: 180
    readonly property int animationSlow: 250

    readonly property int launcherRadius: 22
    readonly property int launcherPadding: 22
}

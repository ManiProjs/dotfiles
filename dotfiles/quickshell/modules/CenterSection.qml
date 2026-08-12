import QtQuick
import Quickshell.Hyprland
import "../theme"

Text {
    id: root

    readonly property var activeWindow: Hyprland.activeToplevel

    text: {
        if (!activeWindow)
            return "Desktop"

            if (activeWindow.title && activeWindow.title.length > 0)
                return activeWindow.title

                if (activeWindow.appId && activeWindow.appId.length > 0)
                    return activeWindow.appId

                    return "Desktop"
    }

    color: Theme.foreground

    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize

    elide: Text.ElideRight

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
}

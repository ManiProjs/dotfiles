pragma Singleton

import Quickshell
import Quickshell.Services.DesktopEntries

QtObject {
    readonly property var apps: DesktopEntries.applications
}

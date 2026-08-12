//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io

import "modules"
import "launcher"
import "popups"

ShellRoot {
  TopBar {
    controlCenter: controlCenter
  }

  Launcher {
    id: launcher
  }

  ControlCenter {
    id: controlCenter
  }

  IpcHandler {
    target: "launcher"

    function toggle(): void {
      launcher.toggle()
    }

    function open(): void {
      launcher.open()
    }

    function close(): void {
      launcher.close()
    }
  }

  IpcHandler {
    target: "controlcenter"

    function toggle(): void {
      controlCenter.toggle()
    }

    function open(): void {
      controlCenter.open()
    }

    function close(): void {
      controlCenter.close()
    }
  }
}

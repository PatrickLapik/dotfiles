import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.components.containers

Loader {
    asynchronous: true

    sourceComponent: Variants {
        model: Quickshell.screens
        StyledWindow {
            required property ShellScreen modelData

            screen: modelData
            aboveWindows: false
            focusable: false

            // Fill the screen behind panels, including their reserved space.
            exclusionMode: ExclusionMode.Ignore

            WlrLayershell.layer: WlrLayer.Background

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            Wallpaper{}
        }
    }
}

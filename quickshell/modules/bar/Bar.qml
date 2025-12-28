import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import qs.components.containers
import qs.config

Scope {
    Variants {
        model: Quickshell.screens

        StyledWindow {
            required property ShellScreen modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: Sizing.barHeight

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusiveZone: implicitHeight

            RowLayout {
                anchors.fill: parent
                spacing: Spacing.xl 

                LeftBar{}
                // Temp spacer
                Rectangle {
                    implicitWidth: 200
                }
                RightBar{}
            }
        }
    }
}

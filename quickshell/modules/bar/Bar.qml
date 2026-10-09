import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import qs.components.containers
import qs.config
import qs.services

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
            color: Colors.withAlpha(Colors.panel, Theme.panelOpacity)

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusiveZone: implicitHeight

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Spacing.panelPadding
                anchors.rightMargin: Spacing.panelPadding
                spacing: Spacing.xl 

                LeftBar{}
                // Temp spacer
                Item {
                    Layout.fillWidth: true
                }
                RightBar{}
            }
        }
    }
}

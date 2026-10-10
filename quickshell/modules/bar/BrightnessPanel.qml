pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.components.containers
import qs.config
import qs.services

Scope {
    WidgetEndpoint {
        name: "brightness"
        openAction: screenName => { popup.screen = Widgets.screenFor(screenName); popup.open() }
        closeAction: () => popup.close()
    }
    ExpandingPopup {
        id: popup
        anchorName: "brightness"
        popupWidth: Sizing.brightnessPanelWidth
        popupHeight: Sizing.brightnessPanelHeight
        onDismissed: Widgets.closed("brightness")
        ColumnLayout {
            anchors.fill: parent
            spacing: Spacing.sm
            RowLayout {
                Layout.fillWidth: true
                ShellIcon { kind: "sun"; tint: Colors.textMuted }
                Text {
                    Layout.fillWidth: true
                    text: Brightness.available ? "Brightness" : "No backlight available"
                    color: Colors.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
                Text {
                    text: Math.round(brightness.value) + "%"
                    color: Colors.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.features: { "tnum": 1 }
                }
            }
            StyledSlider {
                id: brightness
                Layout.fillWidth: true
                from: 1; to: 100
                enabled: Brightness.available
                value: Brightness.percent
                Accessible.name: "Screen brightness"
                onMoved: Brightness.setPercent(value)
            }
            Text {
                Layout.fillWidth: true
                visible: Brightness.error !== ""
                text: "Brightness could not be changed"
                wrapMode: Text.Wrap
                color: Colors.error
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }
}

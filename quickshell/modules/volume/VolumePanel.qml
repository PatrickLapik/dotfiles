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
        name: "volume"
        openAction: screenName => { popup.screen = Widgets.screenFor(screenName); popup.open() }
        closeAction: () => popup.close()
    }
    ExpandingPopup {
        id: popup
        anchorName: "volume"
        expansionMode: "below"
        popupWidth: Sizing.volumePanelWidth
        popupHeight: Sizing.volumePanelHeight
        onDismissed: { outputs.popup.close(); Widgets.closed("volume") }
        ColumnLayout {
            anchors.fill: parent
            spacing: Spacing.sm
            RowLayout {
                Layout.fillWidth: true
                Text { Layout.fillWidth: true; text: "Volume"; color: Colors.text; font.weight: Theme.headingFontWeight; font.family: Theme.headingFontFamily; font.pixelSize: Theme.fontSize }
                Text { text: Audio.available ? Audio.percent + "%" : "—"; color: Colors.primary; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
                StyledButton { text: Audio.muted ? "Unmute" : "Mute"; checked: Audio.muted; enabled: Audio.available; onClicked: Audio.toggleMute() }
                StyledButton { text: "×"; Accessible.name: "Close volume controls"; onClicked: popup.close() }
            }
            Text { text: "Output device"; color: Colors.textMuted; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
            StyledDropdown {
                id: outputs
                Layout.fillWidth: true
                model: Audio.outputChoices
                textRole: "label"
                currentIndex: Audio.outputIndex
                displayText: count ? currentText : "No audio output available"
                enabled: count > 0
                Accessible.name: "Audio output device"
                onActivated: index => Audio.selectOutput(index)
            }
            StyledSlider {
                Layout.fillWidth: true
                from: 0; to: 100
                enabled: Audio.available
                value: Audio.percent
                Accessible.name: "Output volume"
                onMoved: Audio.setPercent(value)
            }
            Item { Layout.fillHeight: true }
        }
    }
}

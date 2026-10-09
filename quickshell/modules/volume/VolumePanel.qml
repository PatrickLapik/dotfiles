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
                Text { text: Audio.available ? Audio.percent + "%" : "—"; color: Colors.textMuted; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; font.features: { "tnum": 1 } }
                StyledIconButton { iconName: Audio.muted ? "muted" : "volume"; Accessible.name: Audio.muted ? "Unmute output" : "Mute output"; checked: Audio.muted; enabled: Audio.available && !Audio.outputBusy; onClicked: Audio.toggleMute() }
            }
            RowLayout {
                Layout.fillWidth: true
                Text { Layout.fillWidth: true; text: "Output device"; color: Colors.textMuted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                StyledButton {
                    Layout.preferredWidth: Sizing.audioDefaultButtonWidth
                    text: Audio.outputBusy ? "Applying…" : Audio.outputIsDefault ? "Default" : "Set as default"
                    enabled: Audio.available && !Audio.outputBusy && !Audio.outputIsDefault
                    flat: true
                    padding: Spacing.xs
                    font.pixelSize: Theme.fontSizeSmall
                    onClicked: Audio.setOutputDefault()
                }
            }
            StyledDropdown {
                id: outputs
                Layout.fillWidth: true
                model: Audio.outputChoices
                textRole: "label"
                currentIndex: Audio.outputIndex
                displayText: count ? currentText : "No audio output available"
                enabled: count > 0 && !Audio.outputBusy
                Accessible.name: "Audio output device"
                onActivated: index => Audio.selectOutput(index)
            }
            StyledSlider {
                Layout.fillWidth: true
                from: 0; to: 100
                enabled: Audio.available && !Audio.outputBusy
                value: Audio.percent
                Accessible.name: "Output volume"
                onMoved: Audio.setPercent(value)
            }
            Text {
                Layout.fillWidth: true
                visible: Audio.outputError !== ""
                text: Audio.outputError
                color: Colors.error
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }
            Item { Layout.fillHeight: true }
        }
    }
}

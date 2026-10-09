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
        name: "microphone"
        openAction: screenName => { popup.screen = Widgets.screenFor(screenName); popup.open() }
        closeAction: () => popup.close()
    }
    ExpandingPopup {
        id: popup
        anchorName: "microphone"
        expansionMode: "below"
        popupWidth: Sizing.volumePanelWidth
        popupHeight: Sizing.volumePanelHeight
        onDismissed: { inputs.popup.close(); Widgets.closed("microphone") }
        ColumnLayout {
            anchors.fill: parent
            spacing: Spacing.sm
            RowLayout {
                Layout.fillWidth: true
                Text { Layout.fillWidth: true; text: "Microphone"; color: Colors.text; font.weight: Theme.headingFontWeight; font.family: Theme.headingFontFamily; font.pixelSize: Theme.fontSize }
                Text { text: Audio.inputAvailable ? Audio.inputPercent + "%" : "—"; color: Colors.textMuted; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; font.features: { "tnum": 1 } }
                StyledIconButton { iconName: Audio.inputMuted ? "microphone-muted" : "microphone"; Accessible.name: Audio.inputMuted ? "Unmute microphone" : "Mute microphone"; checked: Audio.inputMuted; enabled: Audio.inputAvailable && !Audio.inputBusy; onClicked: Audio.toggleInputMute() }
            }
            RowLayout {
                Layout.fillWidth: true
                Text { Layout.fillWidth: true; text: "Input device"; color: Colors.textMuted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                StyledButton {
                    Layout.preferredWidth: Sizing.audioDefaultButtonWidth
                    text: Audio.inputBusy ? "Applying…" : Audio.inputIsDefault ? "Default" : "Set as default"
                    enabled: Audio.inputAvailable && !Audio.inputBusy && !Audio.inputIsDefault
                    flat: true
                    padding: Spacing.xs
                    font.pixelSize: Theme.fontSizeSmall
                    onClicked: Audio.setInputDefault()
                }
            }
            StyledDropdown {
                id: inputs
                Layout.fillWidth: true
                model: Audio.inputChoices
                textRole: "label"
                currentIndex: Audio.inputIndex
                displayText: count ? currentText : "No microphone available"
                enabled: count > 0 && !Audio.inputBusy
                Accessible.name: "Microphone input device"
                onActivated: index => Audio.selectInput(index)
            }
            StyledSlider {
                Layout.fillWidth: true
                from: 0; to: 100
                enabled: Audio.inputAvailable && !Audio.inputBusy
                value: Audio.inputPercent
                Accessible.name: "Microphone input level"
                onMoved: Audio.setInputPercent(value)
            }
            Text {
                Layout.fillWidth: true
                visible: Audio.inputError !== ""
                text: Audio.inputError
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

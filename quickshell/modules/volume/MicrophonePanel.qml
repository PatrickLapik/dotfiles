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
                Text { text: Audio.inputAvailable ? Audio.inputPercent + "%" : "—"; color: Colors.primary; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
                StyledButton { text: Audio.inputMuted ? "Unmute" : "Mute"; checked: Audio.inputMuted; enabled: Audio.inputAvailable; onClicked: Audio.toggleInputMute() }
                StyledButton { text: "×"; Accessible.name: "Close microphone controls"; onClicked: popup.close() }
            }
            Text { text: "Input device"; color: Colors.textMuted; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
            StyledDropdown {
                id: inputs
                Layout.fillWidth: true
                model: Audio.inputChoices
                textRole: "label"
                currentIndex: Audio.inputIndex
                displayText: count ? currentText : "No microphone available"
                enabled: count > 0
                Accessible.name: "Microphone input device"
                onActivated: index => Audio.selectInput(index)
            }
            StyledSlider {
                Layout.fillWidth: true
                from: 0; to: 100
                enabled: Audio.inputAvailable
                value: Audio.inputPercent
                Accessible.name: "Microphone input level"
                onMoved: Audio.setInputPercent(value)
            }
            Item { Layout.fillHeight: true }
        }
    }
}

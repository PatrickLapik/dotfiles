pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
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
        PwNodePeakMonitor {
            id: inputMonitor
            node: Audio.source
            enabled: popup.expanded && Audio.inputAvailable && !Audio.inputMuted
        }
        ColumnLayout {
            anchors.fill: parent
            spacing: Spacing.sm
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
            StyledContainer {
                id: inputMeter
                Layout.fillWidth: true
                implicitHeight: Sizing.audioInputMeterHeight
                radius: Theme.radiusSmall
                color: Colors.surfaceContainerHighest
                border.width: Theme.borderNone
                highlightOpacity: 0
                readonly property real level: inputMonitor.enabled
                    ? Math.sqrt(Math.max(0, Math.min(1, inputMonitor.peak))) : 0
                Accessible.role: Accessible.ProgressBar
                Accessible.name: "Microphone activity"
                Accessible.description: Audio.inputMuted ? "Microphone muted" : "Live microphone input level"
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Colors.primary
                    transform: Scale {
                        origin.x: 0
                        xScale: inputMeter.level
                        Behavior on xScale {
                            NumberAnimation {
                                duration: Animations.enabled ? Animations.feedbackDuration : 0
                                easing.type: Animations.feedbackEasing
                            }
                        }
                    }
                }
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
        }
    }
}

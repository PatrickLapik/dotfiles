pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.components.containers
import qs.config
import qs.services

Scope {
    id: root
    readonly property var actions: [
        { label: "lock", text: "Lock", action: "lock", shortcut: "L", key: Qt.Key_L },
        { label: "logout", text: "Log Out", action: "exit", shortcut: "E", key: Qt.Key_E },
        { label: "suspend", text: "Suspend", action: "suspend", shortcut: "U", key: Qt.Key_U },
        { label: "reboot", text: "Restart", action: "reboot", shortcut: "R", key: Qt.Key_R },
        { label: "shutdown", text: "Power Off", action: "shutdown", shortcut: "S", key: Qt.Key_S }
    ]
    function execute(index: int) {
        const action = actions[index]
        if (!action) return
        popup.close()
        // Use the same action helper as the existing wlogout configuration.
        const script = Quickshell.shellPath("../hypr/scripts/power.sh")
        Quickshell.execDetached(["bash", script, action.action])
    }
    WidgetEndpoint {
        name: "power"
        openAction: screenName => { popup.screen = Widgets.screenFor(screenName); popup.open() }
        closeAction: () => popup.close()
    }
    CenteredPopup {
        id: popup
        popupWidth: Sizing.powerMenuWidth
        popupHeight: Sizing.powerMenuHeight
        keepBarVisible: false
        onOpened: Qt.callLater(() => content.forceActiveFocus())
        onDismissed: Widgets.closed("power")
        ColumnLayout {
            id: content
            anchors.fill: parent
            spacing: Spacing.lg
            focus: true
            Keys.onPressed: event => {
                if (event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier)) return
                const index = root.actions.findIndex(action => action.key === event.key)
                if (index >= 0 && !event.isAutoRepeat) { root.execute(index); event.accepted = true }
            }
            Text { text: "Session"; color: Colors.text; Layout.maximumHeight: Theme.headingLineHeight; font.weight: Theme.headingFontWeight; font.family: Theme.headingFontFamily; font.letterSpacing: Theme.headingLetterSpacing; font.pixelSize: Theme.fontSizeLarge }
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Spacing.md
                Repeater {
                    model: root.actions
                    delegate: StyledContainer {
                        id: card
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Theme.radiusLarge
                        color: mouse.containsMouse || activeFocus ? Colors.primaryContainer : Colors.withAlpha(Colors.primary, Theme.powerCardOpacity)
                        border.color: Colors.primary
                        activeFocusOnTab: true
                        Keys.onReturnPressed: root.execute(index)
                        Keys.onEnterPressed: root.execute(index)
                        Keys.onSpacePressed: root.execute(index)
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: Spacing.md
                            Image {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: Sizing.powerIconSize
                                Layout.preferredHeight: Sizing.powerIconSize
                                source: "file://" + Quickshell.shellPath("../wlogout/icons/" + card.modelData.label + ".png")
                                fillMode: Image.PreserveAspectFit
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: card.modelData.text
                                color: Colors.text
                                font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: card.modelData.shortcut
                                color: Colors.textMuted
                                font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }
                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.execute(card.index)
                        }
                    }
                }
            }
            Text { text: "L  Lock     E  Log Out     U  Suspend     R  Restart     S  Power Off     Esc  Close"; color: Colors.textMuted; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
        }
    }
}

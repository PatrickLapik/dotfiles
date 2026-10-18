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
        { icon: "lock", text: "Lock", action: "lock", shortcut: "L", key: Qt.Key_L },
        { icon: "logout", text: "Log out", action: "exit", shortcut: "E", key: Qt.Key_E },
        { icon: "suspend", text: "Suspend", action: "suspend", shortcut: "U", key: Qt.Key_U },
        { icon: "restart", text: "Restart", action: "reboot", shortcut: "R", key: Qt.Key_R },
        { icon: "power", text: "Power off", action: "shutdown", shortcut: "S", key: Qt.Key_S }
    ]
    function execute(index: int) {
        const action = actions[index]
        if (!action) return
        popup.close()
        if (action.action === "lock") {
            Widgets.open("lock", popup.screen ? popup.screen.name : "")
            return
        }
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
        popupName: "power"
        popupWidth: Sizing.powerMenuWidth
        popupHeight: Sizing.powerMenuHeight
        keepBarVisible: false
        onOpened: Qt.callLater(() => content.forceActiveFocus())
        onDismissed: Widgets.closed("power")
        ColumnLayout {
            id: content
            anchors.fill: parent
            spacing: Spacing.md
            focus: true
            Keys.onPressed: event => {
                if (event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier)) return
                const index = root.actions.findIndex(action => action.key === event.key)
                if (index >= 0 && !event.isAutoRepeat) { root.execute(index); event.accepted = true }
            }
            Text {
                text: "Session"
                color: Colors.text
                font.family: Theme.headingFontFamily
                font.weight: Theme.headingFontWeight
                font.pixelSize: Theme.fontSizeLarge
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Spacing.xs
                Repeater {
                    model: root.actions
                    delegate: ColumnLayout {
                        id: actionRow
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        spacing: Spacing.xs
                        StyledButton {
                            id: actionButton
                            Layout.fillWidth: true
                            Layout.preferredHeight: Sizing.powerMenuRowHeight
                            flat: true
                            text: actionRow.modelData.text
                            font.pixelSize: Theme.fontSizeSmall
                            readonly property color foreground: down ? Colors.onPrimaryContainer
                                : actionRow.modelData.action === "shutdown" ? Colors.error : Colors.text
                            Accessible.name: actionRow.modelData.text
                            onClicked: root.execute(actionRow.index)
                            contentItem: RowLayout {
                                spacing: Spacing.sm
                                ShellIcon {
                                    Layout.preferredWidth: Sizing.barIconSize
                                    Layout.preferredHeight: Sizing.barIconSize
                                    kind: actionRow.modelData.icon
                                    tint: actionButton.foreground
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: actionRow.modelData.text
                                    color: actionButton.foreground
                                    font: actionButton.font
                                    elide: Text.ElideRight
                                }
                                Text {
                                    text: actionRow.modelData.shortcut
                                    color: actionButton.down ? Colors.onPrimaryContainer : Colors.textMuted
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

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
        popupHeight: screen && Math.min(popupWidth, screen.width - Spacing.xl * 2) < Sizing.powerMenuCompactBreakpoint
            ? Sizing.powerMenuCompactHeight : Sizing.powerMenuHeight
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
            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                uniformCellWidths: true
                uniformCellHeights: true
                columns: Math.min(popup.popupMaxWidth, popup.screen ? popup.screen.width - Spacing.xl * 2 : popup.popupMaxWidth)
                    < Sizing.powerMenuCompactBreakpoint ? Sizing.powerMenuCompactColumns : root.actions.length
                rowSpacing: Spacing.sm
                columnSpacing: Spacing.sm
                Repeater {
                    model: root.actions
                    delegate: StyledButton {
                        id: card
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: implicitWidth
                        Layout.minimumWidth: 0
                        Accessible.name: modelData.text
                        onClicked: root.execute(index)
                        contentItem: ColumnLayout {
                            spacing: Spacing.sm
                            Item { Layout.fillHeight: true }
                            ShellIcon {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: Sizing.powerIconSize
                                Layout.preferredHeight: Sizing.powerIconSize
                                kind: card.modelData.icon
                                tint: card.down ? Colors.onPrimaryContainer : Colors.text
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: card.modelData.text
                                color: card.down ? Colors.onPrimaryContainer : Colors.text
                                font: card.font
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: card.modelData.shortcut
                                color: Colors.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                            }
                            Item { Layout.fillHeight: true }
                        }
                    }
                }
            }
        }
    }
}

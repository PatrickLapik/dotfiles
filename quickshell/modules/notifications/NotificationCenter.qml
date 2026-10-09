pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.components.containers
import qs.config
import qs.services

Scope {
    WidgetEndpoint {
        name: "notifications"
        openAction: screenName => { popup.screen = Widgets.screenFor(screenName); popup.open() }
        closeAction: () => popup.close()
    }
    ExpandingPopup {
        id: popup
        anchorName: "notifications"
        popupWidth: Sizing.notificationCenterWidth
        popupHeight: Sizing.notificationCenterHeight
        onExpandedChanged: Notifications.centerOpen = expanded
        onDismissed: Widgets.closed("notifications")
        ColumnLayout {
            anchors.fill: parent
            spacing: Spacing.md
            RowLayout {
                Layout.fillWidth: true
                spacing: Spacing.sm
                Text {
                    Layout.fillWidth: true
                    text: "Notifications"
                    color: Colors.text
                    font.family: Theme.headingFontFamily
                    font.weight: Theme.headingFontWeight
                    font.pixelSize: Theme.fontSizeLarge
                }
                Text {
                    visible: Notifications.count > 0
                    text: Notifications.count
                    color: Colors.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.features: { "tnum": 1 }
                }
                StyledButton {
                    text: "Clear all"
                    flat: true
                    enabled: Notifications.count > 0
                    font.pixelSize: Theme.fontSizeSmall
                    onClicked: Notifications.clearAll()
                }
                StyledIconButton {
                    iconName: Notifications.dnd ? "bell-off" : "bell"
                    checkable: true
                    checked: Notifications.dnd
                    Accessible.name: Notifications.dnd ? "Turn off do not disturb" : "Turn on do not disturb"
                    onClicked: Notifications.dnd = !Notifications.dnd
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: Notifications.count === 0
                    spacing: Spacing.md
                    ShellIcon {
                        Layout.alignment: Qt.AlignHCenter
                        kind: Notifications.dnd ? "bell-off" : "bell"
                        Layout.preferredWidth: Sizing.notificationEmptyIconSize
                        Layout.preferredHeight: Sizing.notificationEmptyIconSize
                        tint: Colors.textMuted
                    }
                    Text {
                        text: Notifications.dnd ? "Do not disturb is on" : "You're all caught up"
                        color: Colors.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }
                }
                ListView {
                    id: list
                    boundsBehavior: Flickable.StopAtBounds
                    anchors.fill: parent
                    clip: true
                    spacing: Spacing.sm
                    model: Notifications.history
                    ScrollBar.vertical: StyledScrollBar {}
                    delegate: NotificationCard {
                        required property var modelData
                        width: list.width - Sizing.scrollBarWidth - Spacing.xs
                        notification: modelData
                        onClicked: forceActiveFocus()
                    }
                }
            }
        }
    }
}

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
        expansionMode: "below"
        popupWidth: Sizing.notificationCenterWidth
        popupHeight: Sizing.notificationCenterHeight
        onExpandedChanged: Notifications.centerOpen = expanded
        onDismissed: Widgets.closed("notifications")
        ColumnLayout {
            anchors.fill: parent
            spacing: Spacing.md
            RowLayout {
                Layout.fillWidth: true
                Text { Layout.fillWidth: true; text: "Notifications · " + Notifications.count; color: Colors.text; Layout.maximumHeight: Theme.headingLineHeight; font.weight: Theme.headingFontWeight; font.family: Theme.headingFontFamily; font.letterSpacing: Theme.headingLetterSpacing; font.pixelSize: Theme.fontSizeLarge }
                StyledButton {
                    padding: Spacing.sm
                    id: closeButton
                    text: "×"
                    Accessible.name: "Close notifications"
                    onClicked: popup.close()
                    background: StyledContainer { radius: Theme.radiusSmall; color: closeButton.hovered ? Colors.surfaceContainerHighest : "transparent" }
                    contentItem: Text { text: closeButton.text; color: Colors.text; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeLarge }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                StyledButton {
                    padding: Spacing.sm
                    id: dndButton
                    text: Notifications.dnd ? "Do not disturb: On" : "Do not disturb: Off"
                    checkable: true
                    checked: Notifications.dnd
                    onClicked: Notifications.dnd = !Notifications.dnd
                    background: StyledContainer { radius: Theme.radiusSmall; color: Notifications.dnd ? Colors.primaryContainer : dndButton.hovered ? Colors.surfaceContainerHighest : Colors.surfaceContainerHigh }
                    contentItem: Text { text: dndButton.text; color: Colors.text; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
                }
                Item { Layout.fillWidth: true }
                StyledButton {
                    padding: Spacing.sm
                    id: clearButton
                    text: "Clear all"
                    enabled: Notifications.count > 0
                    onClicked: Notifications.clearAll()
                    background: StyledContainer { radius: Theme.radiusSmall; color: clearButton.hovered ? Colors.surfaceContainerHighest : Colors.surfaceContainerHigh }
                    contentItem: Text { text: clearButton.text; color: clearButton.enabled ? Colors.text : Colors.textMuted; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Text {
                    anchors.centerIn: parent
                    visible: Notifications.count === 0
                    text: Notifications.dnd ? "No notifications\nDo not disturb is on" : "No notifications"
                    horizontalAlignment: Text.AlignHCenter
                    color: Colors.textMuted
                    font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }
                ListView {
                    boundsBehavior: Flickable.StopAtBounds
                    id: list
                    anchors.fill: parent
                    clip: true
                    spacing: Spacing.sm
                    model: Notifications.history
                    ScrollBar.vertical: StyledScrollBar {}
                    delegate: NotificationCard {
                        required property var modelData
                        width: list.width
                        notification: modelData
                        onClicked: forceActiveFocus()
                    }
                }
            }
        }
    }
}

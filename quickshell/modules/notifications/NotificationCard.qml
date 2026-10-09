pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.components.containers
import qs.config
import qs.services

StyledContainer {
    id: root
    required property var notification
    // Native notification objects can be destroyed before their delegates are removed.
    property var fallbackDetails: ({ id: 0, urgency: 0, actions: [], body: "", summary: "", appName: "", image: "", appIcon: "" })
    readonly property var details: notification || fallbackDetails
    property bool compact: true
    readonly property var visibleActions: details ? details.actions.filter(action =>
        action.identifier !== "default" && !/^(view|open)$/i.test(action.text.trim())) : []
    function iconSource() {
        if (!details) return ""
        if (details.image) return details.image
        const icon = details.appIcon || ""
        if (icon.startsWith("/")) return "file://" + icon
        if (icon.startsWith("file:")) return icon
        return icon ? Quickshell.iconPath(icon, true) : ""
    }
    signal clicked()
    implicitHeight: content.implicitHeight + Spacing.sm * 2
    color: Colors.surfaceContainerHigh
    border.width: Theme.borderWidth
    border.color: details && details.urgency === 2 ? Colors.error : Colors.border
    activeFocusOnTab: true
    Keys.onReturnPressed: clicked()
    Keys.onSpacePressed: clicked()
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
    RowLayout {
        id: content
        x: Spacing.sm
        y: Spacing.sm
        width: root.width - Spacing.sm * 2
        spacing: Spacing.sm
        Image {
            Layout.preferredWidth: Sizing.notificationCompactIconSize
            Layout.preferredHeight: Sizing.notificationCompactIconSize
            Layout.alignment: Qt.AlignTop
            visible: source.toString() !== "" && status !== Image.Error
            source: root.iconSource()
            fillMode: Image.PreserveAspectFit
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Spacing.xs
            Text {
                Layout.fillWidth: true
                text: root.details ? root.details.summary || root.details.appName : ""
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                maximumLineCount: root.compact ? 1 : 6
                elide: Text.ElideRight
                color: Colors.text
                font.weight: Theme.emphasisFontWeight; font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                
            }
            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.details ? root.details.body : ""
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                maximumLineCount: root.compact ? 2 : 12
                elide: Text.ElideRight
                color: Colors.textMuted
                font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }
            Flow {
                Layout.fillWidth: true
                spacing: Spacing.xs
                visible: root.visibleActions.length > 0
                Repeater {
                    model: root.visibleActions
                    delegate: StyledButton {
                        padding: Spacing.xs
                        id: actionButton
                        required property var modelData
                        text: modelData.text || "Open"
                        onClicked: modelData.invoke()
                        background: StyledContainer { radius: Theme.radiusSmall; color: actionButton.hovered ? Colors.primaryContainer : Colors.surfaceContainerHighest }
                        contentItem: Text { text: actionButton.text; textFormat: Text.PlainText; color: Colors.text; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                    }
                }
            }
        }
        StyledButton {
            id: dismiss
            Layout.alignment: Qt.AlignTop
            implicitWidth: Sizing.widgetHeight
            implicitHeight: Sizing.widgetHeight
            padding: Spacing.xs
            text: "×"
            Accessible.name: "Dismiss notification"
            onClicked: root.details && Notifications.dismiss(root.details.id)
            background: StyledContainer { radius: Theme.radiusSmall; color: dismiss.hovered ? Colors.surfaceContainerHighest : "transparent" }
            contentItem: Text { text: dismiss.text; color: Colors.textMuted; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
        }
    }
}

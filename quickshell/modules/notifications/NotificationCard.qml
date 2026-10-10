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
    property bool showTimeout: false
    property real timeoutProgress: 1
    property real minimumHeight: Sizing.notificationCardMinHeight
    property real verticalPadding: Spacing.md
    readonly property string summaryText: details ? details.summary || details.appName : ""
    readonly property string bodyText: details ? details.body : ""
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
    implicitHeight: Math.max(minimumHeight, content.implicitHeight + verticalPadding * 2)
        + (showTimeout ? Spacing.xs + Sizing.notificationProgressHeight : 0)
    border.width: details && details.urgency === 2 ? Theme.borderWidth : Theme.borderNone
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
        y: root.verticalPadding + Math.max(0, (root.height - root.verticalPadding * 2
            - (root.showTimeout ? Spacing.xs + Sizing.notificationProgressHeight : 0)
            - implicitHeight) / 2)
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
            ScrollingText {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.preferredWidth: 0
                visible: root.compact
                text: root.summaryText.replace(/\s+/g, " ")
                color: Colors.text
                font.weight: Theme.emphasisFontWeight; font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }
            Text {
                Layout.fillWidth: true
                visible: !root.compact
                text: root.summaryText
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                maximumLineCount: 6
                elide: Text.ElideRight
                color: Colors.text
                font.weight: Theme.emphasisFontWeight; font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                
            }
            ScrollingText {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.preferredWidth: 0
                visible: root.compact && text !== ""
                text: root.bodyText.replace(/\s+/g, " ")
                color: Colors.textMuted
                font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }
            Text {
                Layout.fillWidth: true
                visible: !root.compact && text !== ""
                text: root.bodyText
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                maximumLineCount: 12
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
                        contentItem: Text { text: actionButton.text; textFormat: Text.PlainText; color: actionButton.hovered ? Colors.onPrimaryContainer : Colors.text; font.weight: Theme.controlFontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                    }
                }
            }
        }
        StyledIconButton {
            id: dismiss
            Layout.alignment: Qt.AlignTop
            implicitWidth: root.compact ? Sizing.notificationDismissSize : Sizing.widgetHeight
            implicitHeight: root.compact ? Sizing.notificationDismissSize : Sizing.widgetHeight
            padding: Spacing.xs
            iconName: "close"
            tint: Colors.textMuted
            Accessible.name: "Dismiss notification"
            onClicked: root.details && Notifications.dismiss(root.details.id)
        }
    }
    StyledContainer {
        id: timeoutTrack
        x: Spacing.sm
        y: root.height - root.verticalPadding - height
        width: root.width - Spacing.sm * 2
        height: Sizing.notificationProgressHeight
        visible: root.showTimeout
        radius: Theme.radiusSmall
        color: Colors.surfaceContainerHighest
        border.width: Theme.borderNone
        highlightOpacity: 0
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: Colors.primary
            transform: Scale {
                origin.x: 0
                xScale: Math.max(0, Math.min(1, root.timeoutProgress))
            }
        }
    }
}

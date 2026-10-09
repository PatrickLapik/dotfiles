import QtQuick
import qs.config
import qs.services

StyledButton {
    id: root
    required property string iconName
    property real iconSize: Sizing.barIconSize
    property color tint: !enabled ? Colors.textMuted
        : highlightInteractions && (down || checked) ? Colors.onPrimaryContainer : Colors.text
    implicitWidth: Math.max(Sizing.widgetHeight, iconSize + padding * 2)
    implicitHeight: Math.max(Sizing.widgetHeight, iconSize + padding * 2)
    padding: Spacing.xs
    flat: true
    contentItem: Item {
        implicitWidth: root.iconSize
        implicitHeight: root.iconSize
        ShellIcon {
            anchors.centerIn: parent
            width: root.iconSize
            height: root.iconSize
            kind: root.iconName
            tint: root.tint
        }
    }
}

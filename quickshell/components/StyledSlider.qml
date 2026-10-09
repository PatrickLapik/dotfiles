import QtQuick
import QtQuick.Controls
import qs.components.containers
import qs.config
import qs.services

Slider {
    id: root
    HoverHandler { cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor }
    background: StyledContainer {
        x: root.leftPadding
        y: root.topPadding + (root.availableHeight - height) / 2
        width: root.availableWidth
        height: Spacing.xs
        radius: Theme.radiusSmall
        color: Colors.surfaceContainerHighest
        StyledContainer { width: parent.width * root.visualPosition; height: parent.height; radius: Theme.radiusSmall; color: Colors.primary }
    }
    handle: StyledContainer {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + (root.availableHeight - height) / 2
        implicitWidth: Sizing.volumeHandleSize
        implicitHeight: Sizing.volumeHandleSize
        radius: Theme.radiusLarge
        color: root.enabled ? Colors.primary : Colors.textMuted
    }
}

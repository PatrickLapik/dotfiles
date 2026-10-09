import QtQuick
import QtQuick.Controls
import qs.components.containers
import qs.config
import qs.services

ScrollBar {
    id: root
    hoverEnabled: true
    policy: ScrollBar.AsNeeded
    visible: size < 1
    padding: Spacing.scrollBarPadding
    implicitWidth: Sizing.scrollBarWidth
    implicitHeight: Sizing.scrollBarWidth
    HoverHandler { cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor }
    background: StyledContainer {
        color: "transparent"
        highlightOpacity: 0
        border.width: Theme.borderNone
    }
    contentItem: StyledContainer {
        implicitWidth: Sizing.scrollBarThumbWidth
        implicitHeight: Sizing.scrollBarThumbWidth
        radius: Theme.radiusSmall
        border.width: Theme.borderNone
        highlightOpacity: 0
        color: root.pressed ? Colors.primary : root.hovered ? Colors.text : Colors.withAlpha(Colors.textMuted, Theme.scrollBarOpacity)
    }
}

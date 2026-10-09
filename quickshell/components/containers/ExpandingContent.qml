import QtQuick
import qs.config

// Lay out once at the expanded size, then reveal cached content with a transform.
Item {
    id: root
    required property ExpandingContainer surface
    property real padding: Spacing.lg
    property real topInset: padding
    property real slideOffset: Spacing.md
    x: (surface.width - surface.expandedWidth) / 2 + padding
    y: topInset + slideOffset * (1 - surface.progress)
    width: surface.expandedWidth - padding * 2
    height: Math.max(0, surface.expandedHeight - topInset - padding)
    opacity: surface.progress
    visible: surface.showing
    enabled: surface.expanded
    layer.enabled: true
}

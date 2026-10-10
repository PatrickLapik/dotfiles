import QtQuick
import qs.config
import "PopupSizing.js" as PopupSizing

// Lay out once at the expanded size, then reveal content with a transform.
Item {
    id: root
    required property ExpandingContainer surface
    property real padding: Spacing.lg
    property real topInset: padding
    property real slideOffset: Spacing.popupSlideOffset
    implicitWidth: PopupSizing.implicitExtent(children, "implicitWidth")
    implicitHeight: PopupSizing.implicitExtent(children, "implicitHeight")
    x: (surface.width - surface.expandedWidth) / 2 + padding
    y: topInset + (surface.belowSource ? 0 : slideOffset * (1 - surface.progress))
    width: surface.expandedWidth - padding * 2
    height: Math.max(0, surface.expandedHeight - topInset - padding)
    opacity: surface.belowSource ? 1 : surface.fadeProgress
    visible: surface.showing
    enabled: surface.expanded
    // Composite the fade during motion, then render settled text directly.
    // Keeping an offscreen layer alive can leave stale glyphs until an interaction repaints it.
    layer.enabled: surface.transitioning && !surface.belowSource
}

import QtQuick
import qs.config

// Grow the painted surface while callers keep content at its final dimensions.
// The surface always animates real geometry, so backdrop blur matches it exactly;
// fades and scales apply only to content (the compositor blurs at full strength
// regardless of surface opacity).
StyledContainer {
    id: root
    property real fullHeight: implicitHeight
    property real fullWidth: implicitWidth
    property real revealProgress: 1
    // 0 grows downward, 0.5 grows from the center, 1 grows upward.
    property real revealOrigin: 0
    // "unfold", "drawer", "zoom" or "cascade"; hosts opt in with Animations.revealStyle.
    property string revealStyle: "unfold"
    // The edge a drawer slides out from: 0 top (drops down), 1 bottom (rises up).
    property real drawerOrigin: 0

    readonly property bool zooming: revealStyle === "zoom"
    readonly property real effectiveOrigin: revealStyle === "drawer" ? drawerOrigin : revealOrigin
    readonly property real clampedProgress: Math.max(0, Math.min(1, revealProgress))
    // Zoom may overshoot past 1 for its spring; other styles stop at full size.
    readonly property real sizeProgress: zooming ? Math.max(0, revealProgress) : clampedProgress
    readonly property real revealWidthFactor: zooming ? sizeProgress : 1
    readonly property real revealedHeight: Math.max(0, fullHeight) * sizeProgress
    // Offset of the surface's top from its settled top, for hosts that position it.
    readonly property real originShift: (fullHeight - height) * effectiveOrigin

    // Cascade holds content back until the surface has partly unfolded.
    readonly property real contentPhase: revealStyle === "cascade"
        ? Math.max(0, Math.min(1, (revealProgress - Animations.cascadeContentStart) / (1 - Animations.cascadeContentStart)))
        : clampedProgress
    readonly property real contentOpacity: zooming || revealStyle === "cascade" ? contentPhase : 1
    // Zoom scales content with the surface so the whole panel grows as one piece.
    readonly property real contentScale: zooming ? sizeProgress : 1
    readonly property real contentShiftY: revealStyle === "cascade" ? (1 - contentPhase) * Spacing.popupRiseOffset : 0
    // Drawers carry content on their moving edge; other styles uncover it in place.
    readonly property real contentOffsetY: (height - fullHeight)
        * (revealStyle === "drawer" ? 1 - effectiveOrigin : effectiveOrigin) + contentShiftY
    readonly property int contentTransformOrigin: effectiveOrigin <= 0 ? Item.Top
        : effectiveOrigin >= 1 ? Item.Bottom : Item.Center

    height: revealedHeight
    clip: true
}

import QtQuick

// Grow the painted surface while callers keep content at its final dimensions.
StyledContainer {
    property real fullHeight: implicitHeight
    property real revealProgress: 1
    // 0 grows downward, 0.5 grows from the center, 1 grows upward.
    property real revealOrigin: 0
    readonly property real revealedHeight: Math.max(0, fullHeight) * Math.max(0, Math.min(1, revealProgress))
    readonly property real contentOffsetY: (height - fullHeight) * revealOrigin
    height: revealedHeight
    clip: true
}

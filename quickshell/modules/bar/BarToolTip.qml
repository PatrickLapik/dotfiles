import QtQuick
import qs.components.containers
import Quickshell
import qs.components
import qs.config
import qs.services

PopupWindow {
    id: root
    required property Item target
    property bool hovered: false
    property string text: ""
    property bool revealed: false
    readonly property bool showing: hovered && revealed && text !== "" && target.visible
    property real progress: showing ? 1 : 0

    visible: showing || progress > 0 || motion.running
    Behavior on progress {
        NumberAnimation {
            id: motion
            duration: !Animations.enabled ? 0 : root.showing ? Animations.revealDuration : Animations.collapseDuration
            easing.type: root.showing ? Animations.revealEasing : Animations.collapseEasing
        }
    }
    color: "transparent"
    grabFocus: false
    // Tooltips must never steal the pointer from their triggering widget.
    mask: Region {}
    BarVisibilityLock {
        screen: root.anchor.window ? root.anchor.window.screen : null
        active: root.hovered || root.visible
    }
    // Measure without wrapping first; then lay out once at the chosen width.
    implicitWidth: Math.min(Sizing.tooltipMaxWidth,
        anchor.window ? Math.max(1, anchor.window.screen.width - Spacing.barMargin * 2) : Sizing.tooltipMaxWidth,
        Math.ceil(measure.implicitWidth) + Spacing.sm * 2)
    implicitHeight: label.implicitHeight + Spacing.sm * 2
    property Text measure: Text {
        visible: false
        text: root.text
        textFormat: Text.PlainText
        font: label.font
        wrapMode: Text.NoWrap
    }

    anchor.window: target.QsWindow.window
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    // Horizontal adjustment is allowed; vertical flipping and sliding are not.
    anchor.adjustment: PopupAdjustment.SlideX
    anchor.onAnchoring: positionBelowButton()

    function positionBelowButton() {
        const window = anchor.window
        if (!window) return
        const point = target.mapToItem(window.contentItem, 0, 0)
        const centeredX = point.x + (target.width - implicitWidth) / 2
        const x = Math.max(0, Math.min(centeredX, Math.max(0, window.width - implicitWidth)))
        // Follow the visible bar edge, including during reveal.
        const y = Math.max(point.y + target.height, ScreenLayout.barBottom) + Spacing.sm
        anchor.rect = Qt.rect(Math.round(x), Math.ceil(y), 1, 1)
    }

    onHoveredChanged: {
        revealed = false
        if (hovered && text !== "") delay.restart()
        else delay.stop()
    }
    onTextChanged: {
        if (text === "") { revealed = false; delay.stop() }
        else if (hovered && !revealed) delay.restart()
    }
    Timer {
        id: delay
        interval: 500
        onTriggered: root.revealed = true
    }
    StyledContainer {
        anchors.fill: parent
        opacity: root.progress
        transform: Translate { y: -Spacing.xs * (1 - root.progress) }
        color: Colors.surfaceContainerHigh
        radius: Theme.radiusSmall
        border.color: Colors.border
        Text {
            id: label
            x: Spacing.sm
            y: Spacing.sm
            width: Math.max(1, root.implicitWidth - Spacing.sm * 2)
            text: root.text
            textFormat: Text.PlainText
            color: Colors.text
            font.weight: Theme.fontWeight; font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
    }
}

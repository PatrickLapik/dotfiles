import QtQuick
import qs.components.containers
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.config
import qs.services

PanelWindow {
    id: root
    required property Item target
    property bool hovered: false
    property string text: ""
    property bool revealed: false
    readonly property bool eligible: hovered && Widgets.activeName === "" && text !== "" && target.visible
    readonly property bool showing: eligible && revealed
    property real progress: showing ? 1 : 0
    property real fadeProgress: showing ? 1 : 0

    visible: showing || progress > 0 || fadeProgress > 0 || motion.running || fade.running
    Behavior on progress {
        NumberAnimation {
            id: motion
            duration: !Animations.enabled ? 0 : root.showing ? Animations.revealDuration : Animations.collapseDuration
            easing.type: root.showing ? Animations.revealEasing : Animations.collapseEasing
        }
    }
    Behavior on fadeProgress {
        NumberAnimation {
            id: fade
            duration: !Animations.enabled ? 0 : root.showing ? Animations.fadeInDuration : Animations.fadeOutDuration
            easing.type: Animations.fadeEasing
        }
    }
    BackgroundEffect.blurRegion: BackdropBlurRegion { target: tooltipSurface; animating: motion.running || fade.running }
    color: "transparent"
    screen: target.QsWindow.window ? target.QsWindow.window.screen : null
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    // Tooltips must never steal the pointer from their triggering widget.
    mask: Region {}
    BarVisibilityLock {
        screen: root.screen
        active: root.eligible || root.visible
    }
    // Measure without wrapping first; then lay out once at the chosen width.
    readonly property real tooltipWidth: Math.min(Sizing.tooltipMaxWidth,
        screen ? Math.max(1, screen.width - Spacing.barMargin * 2) : Sizing.tooltipMaxWidth,
        Math.ceil(measure.implicitWidth) + Spacing.sm * 2)
    readonly property real tooltipHeight: label.implicitHeight + Spacing.sm * 2
    property Text measure: Text {
        visible: false
        text: root.text
        textFormat: Text.PlainText
        font: label.font
        wrapMode: Text.NoWrap
    }

    // A fixed, click-through layer host gives tooltips the same blur path as panels.
    property point targetOrigin: Qt.point(0, 0)
    function positionBelowButton() {
        const host = target.QsWindow.window
        if (host) targetOrigin = target.mapToItem(host.contentItem, 0, 0)
    }
    onShowingChanged: if (showing) positionBelowButton()

    onEligibleChanged: {
        revealed = false
        if (eligible) delay.restart()
        else delay.stop()
    }
    Timer {
        id: delay
        interval: 500
        onTriggered: root.revealed = root.eligible
    }
    StyledContainer {
        id: tooltipSurface
        x: Math.max(Spacing.barMargin, Math.min(root.targetOrigin.x + (root.target.width - width) / 2,
            root.width - width - Spacing.barMargin))
        y: Math.max(root.targetOrigin.y + root.target.height, ScreenLayout.barBottom) + Spacing.sm
        width: root.tooltipWidth
        height: root.tooltipHeight
        opacity: root.fadeProgress
        transform: Translate { y: -Spacing.popupSlideOffset * (1 - root.progress) }
        radius: Theme.radiusSmall
        Text {
            id: label
            x: Spacing.sm
            y: Spacing.sm
            width: Math.max(1, root.tooltipWidth - Spacing.sm * 2)
            text: root.text
            textFormat: Text.PlainText
            color: Colors.text
            font.weight: Theme.fontWeight; font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
    }
}

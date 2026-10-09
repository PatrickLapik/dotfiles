import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.config

// Animate the visible surface inside a fixed-size window, never the window itself.
StyledContainer {
    id: root
    property ShellScreen screen
    property bool expanded: false
    property bool dismissOnOutsideClick: true
    property real collapsedWidth: Sizing.widgetHeight
    property real collapsedHeight: Sizing.barHeight
    property real expandedWidth: Sizing.popupWidth
    property real expandedHeight: Sizing.popupHeight
    property real progress: expanded ? 1 : 0
    property bool anchoredExpansion: false
    property string expansionMode: "replace"
    property real sourceGap: Spacing.sm
    property real minimumSourceBottom: 0
    readonly property bool belowSource: expansionMode === "below"
    readonly property real startY: belowSource ? Math.max(minimumSourceBottom, sourceRect.y + sourceRect.height) + sourceGap : sourceRect.y
    readonly property real startHeight: belowSource ? 0 : sourceRect.height
    property Item sourceItem: null
    property rect sourceRect: Qt.rect(0, 0, collapsedWidth, collapsedHeight)
    property real edgeMargin: Spacing.barMargin
    property point sourceWindowOffset: Qt.point(0, 0)
    readonly property real destinationX: Math.max(edgeMargin,
        Math.min(sourceRect.x + sourceRect.width / 2 - expandedWidth / 2,
            (parent ? parent.width : expandedWidth) - edgeMargin - expandedWidth))
    readonly property real destinationY: belowSource ? startY : Math.max(0,
        Math.min(sourceRect.y, (parent ? parent.height : expandedHeight) - edgeMargin - expandedHeight))
    readonly property bool transitioning: progressAnimation.running
    readonly property bool showing: expanded || progress > 0

    x: anchoredExpansion ? sourceRect.x + (destinationX - sourceRect.x) * progress : 0
    y: anchoredExpansion ? startY + (destinationY - startY) * progress : 0
    width: (anchoredExpansion ? sourceRect.width : collapsedWidth)
        + (expandedWidth - (anchoredExpansion ? sourceRect.width : collapsedWidth)) * progress
    height: (anchoredExpansion ? startHeight : collapsedHeight)
        + (expandedHeight - (anchoredExpansion ? startHeight : collapsedHeight)) * progress
    function expandFrom(item: Item) {
        if (item) {
            const window = item.QsWindow.window
            const point = item.mapToItem(window.contentItem, 0, 0)
            sourceRect = Qt.rect(point.x + sourceWindowOffset.x,
                point.y + sourceWindowOffset.y, item.width, item.height)
            sourceItem = item
            anchoredExpansion = true
        }
        expanded = true
    }
    // The expanding surface replaces its source until it has fully collapsed.
    // Bindings restore the source's original values and bindings on completion.
    Binding {
        target: root.sourceItem
        property: "opacity"
        value: 0
        when: root.showing && !root.belowSource && root.sourceItem !== null
        restoreMode: Binding.RestoreBindingOrValue
    }
    Binding {
        target: root.sourceItem
        property: "enabled"
        value: false
        when: root.showing && !root.belowSource && root.sourceItem !== null
        restoreMode: Binding.RestoreBindingOrValue
    }
    clip: true
    activeFocusOnTab: true
    Keys.onEscapePressed: expanded = false
    Behavior on progress {
        NumberAnimation {
            id: progressAnimation
            duration: !Animations.enabled ? 0 : root.expanded ? Animations.expandDuration : Animations.collapseDuration
            easing.type: root.expanded ? Animations.expandEasing : Animations.collapseEasing
        }
    }
    BarVisibilityLock { screen: root.screen; active: root.showing }

    // A separate fixed-size input window catches clicks beyond the host window.
    // Its hole lets the expanding surface continue receiving its own controls.
    property PanelWindow outsideDismissWindow: PanelWindow {
        id: dismissWindow
        screen: root.screen
        visible: root.expanded && root.dismissOnOutsideClick && root.QsWindow.window !== null
        color: "transparent"
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        readonly property point surfaceOrigin: {
            // These dependencies keep the input hole aligned throughout expansion.
            const x = root.x, y = root.y, width = root.width, height = root.height
            const host = root.QsWindow.window
            return host ? root.mapToItem(host.contentItem, 0, 0) : Qt.point(0, 0)
        }
        mask: Region {
            width: dismissWindow.width
            height: dismissWindow.height

            Region {
                intersection: Intersection.Subtract
                x: dismissWindow.surfaceOrigin.x
                y: dismissWindow.surfaceOrigin.y
                width: root.width
                height: root.height
            }
            BarInputHole { screen: root.screen; width: dismissWindow.width }
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onPressed: root.expanded = false
        }
    }
}

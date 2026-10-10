import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.config
import qs.services
import "PopupSizing.js" as PopupSizing

// A fixed-size host for anchored expansions, with dismissal and keyboard handling.
PanelWindow {
    id: root
    default property alias popupContent: body.data
    property alias backgroundContent: backdrop.data
    property string anchorName: ""
    property string popupName: anchorName
    property string expansionMode: "below"
    property real popupWidth: Sizing.popupWidth
    property real popupHeight: Sizing.popupHeight
    readonly property var sizeLimits: Sizing.popupLimits[popupName] || ({})
    readonly property real availableWidth: Math.max(0, width - Spacing.barMargin * 2)
    readonly property real availableHeight: Math.max(0, height - (panel.belowSource ? panel.startY : Spacing.barTopMargin) - Spacing.barMargin)
    property real popupMinWidth: PopupSizing.dimension(sizeLimits.minWidth, availableWidth, ShellConfig.effectiveUiScale, Sizing.popupMinWidth)
    property real popupMinHeight: PopupSizing.dimension(sizeLimits.minHeight, availableHeight, ShellConfig.effectiveUiScale, Sizing.popupMinHeight)
    property real popupMaxWidth: PopupSizing.dimension(sizeLimits.maxWidth, availableWidth, ShellConfig.effectiveUiScale, sizeLimits.width !== undefined ? availableWidth : popupWidth)
    property real popupMaxHeight: PopupSizing.dimension(sizeLimits.maxHeight, availableHeight, ShellConfig.effectiveUiScale, sizeLimits.height !== undefined ? availableHeight : popupHeight)
    property bool hugContents: sizeLimits.hugContents ?? ShellConfig.popupHugContents
    readonly property real desiredWidth: PopupSizing.extent(sizeLimits.width, popupMinWidth, popupMaxWidth, availableWidth, body.implicitWidth, body.padding, ShellConfig.effectiveUiScale, hugContents)
    readonly property real desiredHeight: PopupSizing.extent(sizeLimits.height, popupMinHeight, popupMaxHeight, availableHeight, body.implicitHeight, body.padding, ShellConfig.effectiveUiScale, hugContents)
    property real layoutWidth: desiredWidth
    property real layoutHeight: desiredHeight
    onDesiredWidthChanged: if (!panel.transitioning) updateSize()
    onDesiredHeightChanged: if (!panel.transitioning) updateSize()
    function updateSize() { layoutWidth = desiredWidth; layoutHeight = desiredHeight }
    Connections {
        target: panel
        function onTransitioningChanged() { if (!panel.transitioning) root.updateSize() }
    }
    readonly property alias surface: panel
    property alias expanded: panel.expanded
    property alias radius: panel.radius
    signal dismissed()
    BackgroundEffect.blurRegion: BackdropBlurRegion { target: panel; animating: panel.transitioning }
    color: "transparent"
    visible: panel.showing
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    // Bar dropdowns must never capture pointer input outside their mask.
    WlrLayershell.keyboardFocus: !expanded ? WlrKeyboardFocus.None
        : barInputHole.pointerInside ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.Exclusive
    function open() {
        if (expanded || panel.preparing) return
        if (panel.progress > 0) { panel.expanded = true; panel.forceActiveFocus(); return }
        panel.captureSource(Widgets.anchorFor(anchorName, screen.name))
        panel.preparing = true
        preparation.frames = 0
        updateSize()
    }
    function close() {
        const wasPreparing = panel.preparing
        panel.preparing = false
        expanded = false
        if (wasPreparing) dismissed()
    }
    FrameAnimation {
        id: preparation
        property int frames: 0
        running: panel.preparing
        onTriggered: {
            if (root.width <= 0 || root.height <= 0) return
            root.updateSize()
            if (++frames < 2) return
            panel.expanded = true
            panel.preparing = false
            panel.forceActiveFocus()
        }
    }
    onExpandedChanged: { if (!expanded) dismissed() }
    property PopupFootprint footprint: PopupFootprint {
        screen: root.screen
        active: panel.showing
        bounds: Qt.rect(panel.destinationX, panel.destinationY, panel.expandedWidth, panel.expandedHeight)
    }
    mask: Region {
        width: root.expanded ? root.width : 0
        height: root.expanded ? root.height : 0
        Region {
            x: panel.x; y: panel.y
            width: root.expanded ? panel.width : 0
            height: root.expanded ? panel.height : 0
        }
        BarInputHole { id: barInputHole; screen: root.screen; width: root.width }
    }
    property Item overlay: Item {
        parent: root.contentItem
        anchors.fill: parent
        MouseArea { anchors.fill: parent; onClicked: root.close() }
        ExpandingContainer {
            id: panel
            screen: root.screen
            expansionMode: root.expansionMode
            sourceGap: Spacing.barPopupGap
            minimumSourceBottom: ScreenLayout.barBottom
            dismissOnOutsideClick: false
            anchoredExpansion: true
            sourceRect: Qt.rect(root.width - Spacing.barMargin - collapsedWidth,
                Spacing.barTopMargin, collapsedWidth, Sizing.barHeight)
            expandedWidth: Math.max(0, Math.min(root.layoutWidth, root.width - Spacing.barMargin * 2))
            expandedHeight: Math.max(0, Math.min(root.layoutHeight,
                root.height - (belowSource ? startY : Spacing.barTopMargin) - Spacing.barMargin))
            Item {
                id: backdrop
                x: (panel.width - width) / 2
                width: panel.expandedWidth
                height: panel.expandedHeight
                opacity: panel.belowSource ? 1 : panel.fadeProgress
            }
            MouseArea { anchors.fill: parent; onClicked: panel.forceActiveFocus() }
            ExpandingContent { id: body; surface: panel }
        }
    }
}

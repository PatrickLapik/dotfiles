import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.config
import qs.services
import "PopupSizing.js" as PopupSizing

// Fixed fullscreen host; position only the surface and retain shared dismissal/animations.
PanelWindow {
    id: root
    default property alias popupContent: body.data
    property int popupWidth: Sizing.popupWidth
    property int popupHeight: Sizing.popupHeight
    property string popupName: ""
    readonly property var sizeLimits: Sizing.popupLimits[popupName] || ({})
    readonly property real availableWidth: Math.max(0, width - edgeMargin * 2)
    readonly property real availableHeight: Math.max(0, height - (alignment & Qt.AlignTop ? topMargin : edgeMargin) - edgeMargin)
    property real popupMinWidth: PopupSizing.dimension(sizeLimits.minWidth, availableWidth, ShellConfig.effectiveUiScale, Sizing.popupMinWidth)
    property real popupMinHeight: PopupSizing.dimension(sizeLimits.minHeight, availableHeight, ShellConfig.effectiveUiScale, Sizing.popupMinHeight)
    property real popupMaxWidth: PopupSizing.dimension(sizeLimits.maxWidth, availableWidth, ShellConfig.effectiveUiScale, sizeLimits.width !== undefined ? availableWidth : popupWidth)
    property real popupMaxHeight: PopupSizing.dimension(sizeLimits.maxHeight, availableHeight, ShellConfig.effectiveUiScale, sizeLimits.height !== undefined ? availableHeight : popupHeight)
    property bool hugContents: sizeLimits.hugContents ?? ShellConfig.popupHugContents
    readonly property real desiredWidth: PopupSizing.extent(sizeLimits.width, popupMinWidth, popupMaxWidth, availableWidth, body.implicitWidth, padding, ShellConfig.effectiveUiScale, hugContents)
    readonly property real desiredHeight: PopupSizing.extent(sizeLimits.height, popupMinHeight, popupMaxHeight, availableHeight, body.implicitHeight, padding, ShellConfig.effectiveUiScale, hugContents)
    property real layoutWidth: desiredWidth
    property real layoutHeight: desiredHeight
    onDesiredWidthChanged: if (!motion.running) updateSize()
    onDesiredHeightChanged: if (!motion.running) updateSize()
    function updateSize() { layoutWidth = desiredWidth; layoutHeight = desiredHeight }
    property int padding: Spacing.lg
    property int edgeMargin: Spacing.xl
    property int alignment: Qt.AlignCenter
    property int topMargin: Math.max(Spacing.screenTopMargin, edgeMargin)
    property int rightMargin: edgeMargin
    readonly property alias surface: popupSurface
    property bool keepBarVisible: true
    signal opened()
    signal dismissed()

    property bool isOpen: false
    property bool preparing: false
    property bool revealed: false
    property real progress: revealed ? 1 : 0
    visible: isOpen || progress > 0 || motion.running
    Behavior on progress {
        NumberAnimation {
            id: motion
            duration: !Animations.enabled ? 0 : root.isOpen ? Animations.expandDuration : Animations.collapseDuration
            easing.type: root.isOpen ? Animations.expandEasing : Animations.collapseEasing
            onRunningChanged: if (!running) root.updateSize()
        }
    }
    BackgroundEffect.blurRegion: BackdropBlurRegion { target: popupSurface; animating: motion.running }
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    // Release the compositor's exclusive pointer capture over the bar input hole.
    WlrLayershell.keyboardFocus: !root.isOpen ? WlrKeyboardFocus.None
        : barInputHole.pointerInside ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.Exclusive

    // Keep the screen-edge bar interactive above this full-screen dismiss area.
    mask: Region {
        width: root.isOpen ? root.width : 0
        height: root.isOpen ? root.height : 0
        BarInputHole { id: barInputHole; screen: root.screen; width: root.width }
    }

    function open() { isOpen = true }
    function close() { isOpen = false }
    function toggle() { isOpen = !isOpen }
    onIsOpenChanged: {
        if (isOpen) {
            preparing = progress <= 0
            preparation.frames = 0
            if (!preparing) revealed = true
            updateSize()
            overlay.forceActiveFocus()
            opened()
        } else {
            preparing = false
            revealed = false
            dismissed()
        }
    }
    FrameAnimation {
        id: preparation
        property int frames: 0
        running: root.preparing
        onTriggered: {
            if (root.width <= 0 || root.height <= 0) return
            root.updateSize()
            if (++frames < 2) return
            root.preparing = false
            root.revealed = true
        }
    }

    property BarVisibilityLock barLock: BarVisibilityLock {
        screen: root.screen
        active: root.visible && root.keepBarVisible
    }
    property PopupFootprint footprint: PopupFootprint {
        screen: root.screen
        active: root.visible
        bounds: Qt.rect(popupSurface.x, popupSurface.y, popupSurface.width, popupSurface.height)
    }

    // An explicit property keeps internal items out of the public content alias.
    property Item overlay: Item {
        parent: root.contentItem
        anchors.fill: parent
        enabled: root.isOpen
        focus: true
        Keys.onEscapePressed: event => { root.close(); event.accepted = true }
        MouseArea {
            anchors.fill: parent
            onClicked: event => {
                const inside = event.x >= popupSurface.x && event.x < popupSurface.x + popupSurface.width
                    && event.y >= popupSurface.y && event.y < popupSurface.y + popupSurface.height
                if (!inside) root.close()
            }
        }
        RevealingContainer {
            id: popupSurface
            color: Colors.withAlpha(Colors.panel, Theme.panelOpacity)
            x: root.alignment & Qt.AlignRight
                ? Math.max(0, parent.width - width - root.rightMargin)
                : root.alignment & Qt.AlignLeft ? root.edgeMargin : (parent.width - width) / 2
            y: root.alignment & Qt.AlignTop
                ? Math.min(root.topMargin, Math.max(0, parent.height - fullHeight - root.edgeMargin))
                : root.alignment & Qt.AlignBottom ? parent.height - height - root.edgeMargin : (parent.height - height) / 2
            width: Math.min(root.layoutWidth, Math.max(0, parent.width - root.edgeMargin * 2))
            fullHeight: Math.min(root.layoutHeight, Math.max(0, parent.height - (root.alignment & Qt.AlignTop ? root.topMargin : root.edgeMargin) - root.edgeMargin))
            revealProgress: root.progress
            revealOrigin: root.alignment & Qt.AlignTop ? 0 : root.alignment & Qt.AlignBottom ? 1 : 0.5
            Item {
                id: body
                implicitWidth: PopupSizing.implicitExtent(children, "implicitWidth")
                implicitHeight: PopupSizing.implicitExtent(children, "implicitHeight")
                x: root.padding
                y: popupSurface.contentOffsetY + root.padding
                width: Math.max(0, popupSurface.width - root.padding * 2)
                height: Math.max(0, popupSurface.fullHeight - root.padding * 2)
            }
        }
    }
}

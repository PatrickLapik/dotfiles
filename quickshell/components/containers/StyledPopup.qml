import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.config

// Fixed fullscreen host; position only the surface and retain shared dismissal/animations.
PanelWindow {
    id: root
    default property alias popupContent: body.data
    property int popupWidth: Sizing.popupWidth
    property int popupHeight: Sizing.popupHeight
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
    property real progress: isOpen ? 1 : 0
    visible: isOpen || progress > 0 || motion.running
    Behavior on progress {
        NumberAnimation {
            id: motion
            duration: !Animations.enabled ? 0 : root.isOpen ? Animations.expandDuration : Animations.collapseDuration
            easing.type: root.isOpen ? Animations.expandEasing : Animations.collapseEasing
        }
    }
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
            overlay.forceActiveFocus()
            opened()
        } else dismissed()
    }

    property BarVisibilityLock barLock: BarVisibilityLock {
        screen: root.screen
        active: root.visible && root.keepBarVisible
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
        StyledContainer {
            id: popupSurface
            x: root.alignment & Qt.AlignRight
                ? Math.max(0, parent.width - width - root.rightMargin)
                : root.alignment & Qt.AlignLeft ? root.edgeMargin : (parent.width - width) / 2
            y: root.alignment & Qt.AlignTop
                ? Math.min(root.topMargin, Math.max(0, parent.height - height - root.edgeMargin))
                : root.alignment & Qt.AlignBottom ? parent.height - height - root.edgeMargin : (parent.height - height) / 2
            width: Math.min(root.popupWidth, Math.max(0, parent.width - root.edgeMargin * 2))
            height: Math.min(root.popupHeight, Math.max(0, parent.height - (root.alignment & Qt.AlignTop ? root.topMargin : root.edgeMargin) - root.edgeMargin))
            opacity: root.progress
            transform: Translate { y: Spacing.lg * (1 - root.progress) }
            Item {
                id: body
                anchors.fill: parent
                anchors.margins: root.padding
            }
        }
    }
}

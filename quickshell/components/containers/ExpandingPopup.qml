import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.config
import qs.services

// A fixed-size host for anchored expansions, with dismissal and keyboard handling.
PanelWindow {
    id: root
    default property alias popupContent: body.data
    property alias backgroundContent: backdrop.data
    property string anchorName: ""
    property string expansionMode: "below"
    property real popupWidth: Sizing.popupWidth
    property real popupHeight: Sizing.popupHeight
    readonly property alias surface: panel
    property alias expanded: panel.expanded
    property alias radius: panel.radius
    signal dismissed()
    color: "transparent"
    visible: panel.showing
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    // Bar dropdowns must never capture pointer input outside their mask.
    WlrLayershell.keyboardFocus: expanded ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    function open() {
        panel.expandFrom(Widgets.anchorFor(anchorName, screen.name))
        Qt.callLater(() => panel.forceActiveFocus())
    }
    function close() { expanded = false }
    onExpandedChanged: { if (!expanded) dismissed() }
    mask: Region {
        width: root.expanded ? root.width : 0
        height: root.expanded ? root.height : 0
        Region { x: panel.x; y: panel.y; width: panel.width; height: panel.height }
        BarInputHole { screen: root.screen; width: root.width }
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
            expandedWidth: Math.max(0, Math.min(root.popupWidth, root.width - Spacing.barMargin * 2))
            expandedHeight: Math.max(0, Math.min(root.popupHeight,
                root.height - (belowSource ? startY : Spacing.barTopMargin) - Spacing.barMargin))
            color: Colors.panel
            Item {
                id: backdrop
                x: (panel.width - width) / 2
                width: panel.expandedWidth
                height: panel.expandedHeight
                opacity: panel.progress
            }
            MouseArea { anchors.fill: parent; onClicked: panel.forceActiveFocus() }
            ExpandingContent { id: body; surface: panel }
        }
    }
}

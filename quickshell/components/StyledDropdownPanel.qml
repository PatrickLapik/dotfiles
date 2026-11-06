import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell as QS
import Quickshell.Wayland
import qs.components.containers
import qs.config
import qs.services

PanelWindow {
    id: menu
    required property var dropdown
    required property Component optionDelegate
    function focusMenu() {
        choices.currentIndex = dropdown.currentIndex >= 0 ? dropdown.currentIndex : 0
        menuContent.forceActiveFocus()
    }
    PopupFootprint {
        screen: menu.screen
        active: menu.visible
        bounds: Qt.rect(menu.origin.x, menu.origin.y, dropdown.width, menu.menuHeight)
    }
    screen: dropdown.QsWindow.window ? dropdown.QsWindow.window.screen : null
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: QS.ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    // Keep topbar actions reachable while a selection menu is open.
    WlrLayershell.keyboardFocus: !dropdown.popup.visible ? WlrKeyboardFocus.None
        : barInputHole.pointerInside ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.Exclusive
    BackgroundEffect.blurRegion: BackdropBlurRegion { target: menuContent; animating: menu.progress > 0 && menu.progress < 1 }
    color: "transparent"
    readonly property point origin: {
        const host = dropdown.QsWindow.window
        const point = host ? dropdown.mapToItem(host.contentItem, 0, dropdown.height + Spacing.xs) : Qt.point(0, 0)
        return Qt.point(Math.max(0, Math.min(point.x, width - dropdown.width)), Math.min(point.y, height - menuHeight))
    }
    readonly property real menuHeight: Math.min(Sizing.dropdownMaxHeight, dropdown.count * Sizing.dropdownRowHeight)
    mask: QS.Region {
        width: dropdown.popup.visible ? menu.width : 0
        height: dropdown.popup.visible ? menu.height : 0
        BarInputHole { id: barInputHole; screen: menu.screen; width: menu.width }
    }
    MouseArea { anchors.fill: parent; onPressed: dropdown.popup.close() }
    property real progress: dropdown.popup.visible ? 1 : 0
    visible: !dropdown.windowedHost && (dropdown.popup.visible || progress > 0 || motion.running)
    onVisibleChanged: { if (!visible && dropdown.popup.visible) dropdown.popup.close() }
    Behavior on progress {
        NumberAnimation {
            id: motion
            duration: !Animations.enabled ? 0 : dropdown.popup.visible ? Animations.expandDuration : Animations.collapseDuration
            easing.type: dropdown.popup.visible ? Animations.expandEasing : Animations.collapseEasing
        }
    }
    StyledContainer {
        id: menuMask
        width: menuContent.width
        height: menuContent.height
        radius: menuContent.radius
        color: "white"
        highlightOpacity: 0
        border.width: Theme.borderNone
        visible: false
        layer.enabled: true
    }
    RevealingContainer {
        id: menuContent
        x: menu.origin.x
        y: menu.origin.y
        width: dropdown.width
        fullHeight: menu.menuHeight
        revealProgress: menu.progress
        // Inherit the shared panel opacity, palette gradient, and border defaults.
        radius: Theme.radiusSmall
        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: menuMask
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
        }
        enabled: dropdown.popup.visible
        focus: true
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Down) choices.currentIndex = Math.min(dropdown.count - 1, choices.currentIndex + 1)
            else if (event.key === Qt.Key_Up) choices.currentIndex = Math.max(0, choices.currentIndex - 1)
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) dropdown.choose(choices.currentIndex)
            else if (event.key === Qt.Key_Escape || event.key === Qt.Key_Tab) dropdown.popup.close()
            else return
            choices.positionViewAtIndex(choices.currentIndex, ListView.Contain)
            event.accepted = true
        }
        ListView {
            id: choices
            width: menuContent.width
            height: menuContent.fullHeight
            clip: true
            model: dropdown.model
            ScrollBar.vertical: StyledScrollBar {}
            delegate: menu.optionDelegate
        }
    }
}

import QtQuick
import Quickshell
import qs.services

// Publish the settled footprint until the visible surface finishes closing.
QtObject {
    id: root
    required property ShellScreen screen
    required property rect bounds
    property bool active: false

    function update() {
        if (active && screen) PopupLayout.setSurface(root, screen, bounds)
        else PopupLayout.removeSurface(root)
    }
    onScreenChanged: update()
    onBoundsChanged: update()
    onActiveChanged: update()
    Component.onCompleted: update()
    Component.onDestruction: PopupLayout.removeSurface(root)
}

import QtQuick
import Quickshell
import qs.services

// Register the container a widget should grow from, per monitor.
QtObject {
    id: root
    required property string name
    required property Item target
    property ShellScreen screen: target.QsWindow.window ? target.QsWindow.window.screen : null
    property string registeredScreen: ""
    function update() {
        if (registeredScreen !== "") Widgets.removeAnchor(name, registeredScreen, root)
        registeredScreen = screen ? screen.name : ""
        if (registeredScreen !== "") Widgets.setAnchor(name, registeredScreen, root, target)
    }
    onScreenChanged: update()
    onTargetChanged: update()
    Component.onCompleted: update()
    Component.onDestruction: Widgets.removeAnchor(name, registeredScreen, root)
}

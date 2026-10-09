import QtQuick
import Quickshell
import qs.services

// One owner, one lock. Closing or destroying the owner releases it automatically.
QtObject {
    id: root
    property ShellScreen screen
    property bool active: false
    property int token: -1
    property bool initialized: false

    function update() {
        if (!initialized) return
        BarVisibility.release(token)
        token = active && screen ? BarVisibility.acquire(screen) : -1
    }
    onActiveChanged: update()
    onScreenChanged: update()
    Component.onCompleted: { initialized = true; update() }
    Component.onDestruction: BarVisibility.release(token)
}

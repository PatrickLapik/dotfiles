import QtQuick
import Quickshell.Hyprland
import qs.services

// Bind a service's level and availability; show only actual changes after discovery.
FloatingIndicator {
    id: root
    property bool available: false
    property var sourceIdentity: null
    property bool initialized: false
    property bool completed: false
    property var previousSource: null
    property real previousValue: 0
    property bool previousSubdued: false

    function sync() {
        if (!completed) return
        if (!available) {
            initialized = false
            active = false
            return
        }
        const changed = initialized && previousSource === sourceIdentity
            && (previousValue !== value || previousSubdued !== subdued)
        previousSource = sourceIdentity
        previousValue = value
        previousSubdued = subdued
        initialized = true
        if (changed)
            showFor(Widgets.screenFor(Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""))
    }

    // Coalesce derived property changes so switching devices resets the baseline.
    onValueChanged: Qt.callLater(root.sync)
    onSubduedChanged: Qt.callLater(root.sync)
    onAvailableChanged: Qt.callLater(root.sync)
    onSourceIdentityChanged: Qt.callLater(root.sync)
    Component.onCompleted: {
        completed = true
        sync()
    }
}

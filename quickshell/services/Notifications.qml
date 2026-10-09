pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications as Native
import qs.config

Singleton {
    id: root
    property bool dnd: false
    property bool centerOpen: false
    property var order: []
    property var toasts: []
    property int serial: 0
    readonly property var history: server.trackedNotifications.values
        .filter(n => !n.transient)
        .sort((a, b) => order.indexOf(a.id) - order.indexOf(b.id))
    readonly property int count: history.length

    function hideToast(id) { toasts = toasts.filter(t => t.id !== id) }
    function hideAllToasts() {
        const transient = server.trackedNotifications.values.filter(n => n.transient)
        toasts = []
        for (const n of transient) n.expire()
    }
    function dismiss(id) {
        hideToast(id)
        const n = server.trackedNotifications.values.find(n => n.id === id)
        if (n) n.dismiss()
    }
    function reconcile() {
        const ids = server.trackedNotifications.values.map(n => n.id)
        toasts = toasts.filter(t => ids.includes(t.id))
        order = order.filter(id => ids.includes(id))
    }
    function clearAll() {
        toasts = []
        for (const n of server.trackedNotifications.values.slice()) n.dismiss()
    }
    function timeout(id) {
        hideToast(id)
        const n = server.trackedNotifications.values.find(n => n.id === id)
        // Regular notifications remain available in the center after their toast hides.
        if (n && n.transient) n.expire()
    }
    onDndChanged: if (dnd) hideAllToasts()
    onCenterOpenChanged: if (centerOpen) hideAllToasts()

    Native.NotificationServer {
        id: server
        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: false
        actionsSupported: true
        imageSupported: true
        onNotification: n => {
            n.tracked = true
            root.order = [n.id].concat(root.order.filter(id => id !== n.id))
            root.hideToast(n.id)
            if (root.dnd || root.centerOpen) {
                if (n.transient) n.expire()
            } else if (!n.lastGeneration) {
                const screenName = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""
                // Keep display data available while a closed notification slides out.
                const snapshot = { id: n.id, appName: n.appName, appIcon: n.appIcon,
                    image: n.image, summary: n.summary, body: n.body, urgency: n.urgency,
                    actions: n.actions.map(action => ({ text: action.text, identifier: action.identifier })) }
                const toast = { id: n.id, notification: n, snapshot: snapshot, screenName: screenName, serial: ++root.serial }
                const next = root.toasts.concat([toast])
                const removed = next.slice(0, Math.max(0, next.length - Sizing.notificationMaxToasts))
                root.toasts = next.slice(-Sizing.notificationMaxToasts)
                for (const old of removed) root.timeout(old.id)
            }
            while (root.history.length > Sizing.notificationHistoryLimit)
                root.history[root.history.length - 1].dismiss()
        }
        onTrackedNotificationsChanged: root.reconcile()
    }
    // The ObjectModel stays the same when notifications close; its values change.
    Connections {
        target: server.trackedNotifications
        function onValuesChanged() { root.reconcile() }
    }
}

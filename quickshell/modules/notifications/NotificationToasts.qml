pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.config
import qs.services

Scope {
    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            id: window
            required property var modelData
            screen: modelData
            readonly property var entries: Notifications.toasts.filter(t => (t.screenName || Quickshell.screens[0].name) === modelData.name)
            visible: presentation.count > 0
            color: "transparent"
            anchors { top: true; bottom: true; right: true }
            margins { right: Spacing.barMargin }
            implicitWidth: Math.min(Sizing.notificationToastWidth, screen.width - Spacing.barMargin * 2)
            // Keep the native window fixed; only the stack and its input mask move.
            mask: Region { item: stack }
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            // Preserve delegates until their slide-out finishes. Updating this model
            // by id also avoids replaying every card's reveal on a list update.
            ListModel { id: presentation; dynamicRoles: true }
            function syncEntries() {
                for (let i = 0; i < presentation.count; ++i) {
                    const current = presentation.get(i)
                    const entry = entries.find(t => t.id === current.entry.id)
                    if (entry) {
                        presentation.setProperty(i, "entry", entry)
                        presentation.setProperty(i, "closing", false)
                    } else presentation.setProperty(i, "closing", true)
                }
                for (const entry of entries) {
                    let exists = false
                    for (let i = 0; i < presentation.count; ++i)
                        if (presentation.get(i).entry.id === entry.id) exists = true
                    if (!exists) presentation.append({entry: entry, closing: false})
                }
            }
            function finishExit(id) {
                for (let i = 0; i < presentation.count; ++i) {
                    const row = presentation.get(i)
                    if (row.entry.id === id && row.closing) {
                        presentation.remove(i)
                        return
                    }
                }
            }
            onEntriesChanged: syncEntries()
            Component.onCompleted: syncEntries()
            Column {
                id: stack
                width: parent.width
                y: ScreenLayout.topOffset(window.screen, Spacing.notificationTopMargin, Spacing.notificationBarGap)
                spacing: Spacing.sm
                clip: true
                move: Transition {
                    NumberAnimation { properties: "y"; duration: Animations.enabled ? Animations.collapseDuration : 0; easing.type: Animations.collapseEasing }
                }
                Repeater {
                    model: presentation
                    delegate: Item {
                        id: toast
                        required property var entry
                        required property bool closing
                        width: stack.width
                        property real retainedHeight: card.implicitHeight
                        implicitHeight: closing ? retainedHeight : card.implicitHeight
                        Binding { target: toast; property: "retainedHeight"; value: card.implicitHeight; when: !toast.closing; restoreMode: Binding.RestoreNone }
                        property real reveal: 0
                        Component.onCompleted: reveal = closing ? 0 : 1
                        onClosingChanged: {
                            reveal = closing ? 0 : 1
                            if (closing && reveal === 0) Qt.callLater(() => window.finishExit(entry.id))
                        }
                        onRevealChanged: if (closing && reveal === 0) Qt.callLater(() => window.finishExit(entry.id))
                        Behavior on reveal {
                            NumberAnimation {
                                duration: !Animations.enabled ? 0 : toast.closing ? Animations.collapseDuration : Animations.revealDuration
                                easing.type: toast.closing ? Animations.collapseEasing : Animations.revealEasing
                            }
                        }
                        NotificationCard {
                            id: card
                            width: parent.width
                            height: implicitHeight
                            notification: toast.closing ? null : toast.entry.notification
                            fallbackDetails: toast.entry.snapshot
                            enabled: !toast.closing
                            compact: true
                            transform: Translate { x: (toast.width + Spacing.barMargin) * (1 - toast.reveal) }
                            onClicked: Widgets.open("notifications", window.screen.name)
                        }
                        HoverHandler { id: hover }
                        BarVisibilityLock { screen: window.screen; active: hover.hovered && !toast.closing }
                        Timer {
                            readonly property real expiry: toast.entry.notification ? toast.entry.notification.expireTimeout : -1
                            // The installed Quickshell API exposes the D-Bus timeout in milliseconds.
                            interval: expiry > 0 ? expiry : Theme.notificationTimeout
                            running: !toast.closing && expiry !== 0 && !hover.hovered
                            onTriggered: Notifications.timeout(toast.entry.id)
                        }
                    }
                }
            }
        }
    }
}

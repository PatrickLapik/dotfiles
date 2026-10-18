pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.components.containers
import qs.config
import qs.services

Scope {
    // Keep this inline so hot reload does not depend on discovering a new QML file.
    component ToastCountdown: QtObject {
        id: countdownRoot
        property real duration: Theme.notificationTimeout
        property bool active: true
        property bool paused: false
        property real remaining: duration
        property real lastTick: 0
        readonly property real progress: duration > 0 ? Math.max(0, Math.min(1, remaining / duration)) : 0
        signal expired()

        function reset() {
            remaining = duration
            lastTick = Date.now()
        }
        function advance(now) {
            if (!active || paused || duration <= 0 || remaining <= 0) return
            remaining = Math.max(0, remaining - Math.max(0, now - lastTick))
            lastTick = now
            if (remaining === 0) expired()
        }
        onDurationChanged: reset()
        Component.onCompleted: reset()
        property Timer clock: Timer {
            interval: Theme.notificationProgressInterval
            repeat: true
            running: countdownRoot.active && !countdownRoot.paused && countdownRoot.duration > 0 && countdownRoot.remaining > 0
            onRunningChanged: countdownRoot.lastTick = Date.now()
            onTriggered: countdownRoot.advance(Date.now())
        }
    }
    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            id: window
            required property var modelData
            screen: modelData
            readonly property var entries: Notifications.toasts.filter(t => (t.screenName || Quickshell.screens[0].name) === modelData.name)
            // Keep the native surface mapped between toasts. Mapping/unmapping lets
            // the compositor animate a second time around the card's own slide.
            // An empty stack has no input region and paints no pixels.
            visible: true
            property var blurRegions: []
            BackgroundEffect.blurRegion: Region {
                Region { regions: window.blurRegions }
                // The slide continues beyond this window's right edge. Submit an
                // empty region once it leaves, not a nonempty off-surface region:
                // Hyprland can otherwise blur the entire host when clipping it.
                Region {
                    intersection: Intersection.Intersect
                    width: window.width
                    height: window.height
                }
            }
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
                // Regions track the card itself; also invalidate when its ancestors move.
                onYChanged: window.blurRegions.forEach(region => region.changed())
                y: PopupLayout.notificationTop(window.screen,
                    window.screen.width - Spacing.barMargin - width, width,
                    ScreenLayout.topOffset(window.screen, Spacing.notificationTopMargin, Spacing.notificationBarGap),
                    Spacing.notificationBarGap)
                spacing: Spacing.sm
                clip: true
                Behavior on y {
                    NumberAnimation {
                        duration: Animations.enabled ? Animations.revealDuration : 0
                        easing.type: Animations.revealEasing
                    }
                }
                move: Transition {
                    NumberAnimation { properties: "y"; duration: Animations.enabled ? Animations.collapseDuration : 0; easing.type: Animations.collapseEasing }
                }
                Repeater {
                    model: presentation
                    delegate: Item {
                        id: toast
                        onYChanged: blurRegion.changed()
                        required property var entry
                        required property bool closing
                        readonly property int serial: entry.serial
                        onSerialChanged: Qt.callLater(() => countdown.reset())
                        width: stack.width
                        property real retainedHeight: card.implicitHeight
                        implicitHeight: closing ? retainedHeight : card.implicitHeight
                        Binding { target: toast; property: "retainedHeight"; value: card.implicitHeight; when: !toast.closing; restoreMode: Binding.RestoreNone }
                        property real reveal: 0
                        property BackdropBlurRegion blurRegion: BackdropBlurRegion {
                            target: card
                            // Opaque cards do not need a backdrop effect. Keep offscreen
                            // delegates from briefly registering a blur region on creation.
                            active: Theme.backdropBlurEnabled && toast.reveal > 0 && card.color.a < 1
                            animating: toast.reveal > 0 && toast.reveal < 1
                        }
                        Component.onCompleted: {
                            window.blurRegions = window.blurRegions.concat([blurRegion])
                            reveal = closing ? 0 : 1
                        }
                        Component.onDestruction: window.blurRegions = window.blurRegions.filter(region => region !== blurRegion)
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
                            // Keep the live data through ordinary timeout; fallbackDetails
                            // still retains the visual if a transient native object closes.
                            notification: toast.entry.notification
                            fallbackDetails: toast.entry.snapshot
                            enabled: !toast.closing
                            compact: true
                            showTimeout: countdown.duration > 0
                            timeoutProgress: countdown.progress
                            transform: Translate { x: (toast.width + Spacing.barMargin) * (1 - toast.reveal) }
                            onClicked: Notifications.activate(toast.entry.notification, window.screen.name)
                        }
                        HoverHandler { id: hover }
                        BarVisibilityLock { screen: window.screen; active: hover.hovered && !toast.closing }
                        ToastCountdown {
                            id: countdown
                            // Keep the timeout after the native notification closes, like its display data.
                            readonly property real expiry: toast.entry.snapshot.expireTimeout ?? -1
                            duration: expiry === 0 ? 0 : expiry > 0 ? expiry : Theme.notificationTimeout
                            active: !toast.closing
                            paused: hover.hovered
                            onExpired: Notifications.timeout(toast.entry.id)
                        }
                    }
                }
            }
        }
    }
}

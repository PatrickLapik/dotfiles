import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config

Scope {
    id: root
    property string joke: LockConfig.fallbackJoke
    property bool revealed: false
    property bool unlocking: false
    property real progress: 0
    NumberAnimation {
        id: transition
        target: root
        property: "progress"
        duration: !Animations.enabled ? 0 : root.unlocking ? Animations.collapseDuration : Animations.expandDuration
        easing.type: root.unlocking ? Animations.collapseEasing : Animations.expandEasing
        onFinished: {
            if (!root.unlocking) return
            sessionLock.locked = false
            Qt.callLater(() => Qt.quit())
        }
    }
    // Present the initial frame on all lock surfaces before revealing content.
    FrameAnimation {
        property int frames: 0
        running: sessionLock.secure && !root.revealed && !root.unlocking
        onTriggered: {
            if (++frames < 2) return
            root.revealed = true
            transition.to = 1
            transition.start()
        }
    }
    LockAuth {
        id: authentication
        onAuthenticated: {
            if (root.unlocking) return
            transition.stop()
            root.unlocking = true
            transition.to = 0
            transition.start()
        }
    }
    WlSessionLock {
        id: sessionLock
        WlSessionLockSurface {
            id: surface
            color: "black"
            LockView {
                anchors.fill: parent
                auth: authentication
                progress: root.progress
                enabled: !root.unlocking
                joke: root.joke
                backgroundSource: Quickshell.env("QS_LOCK_BACKGROUNDS")
                    ? "file://" + Quickshell.env("QS_LOCK_BACKGROUNDS") + "/" + encodeURIComponent(encodeURIComponent(surface.screen.name)) + ".png" : ""
            }
        }
    }
    Component.onCompleted: {
        Quickshell.watchFiles = false
        sessionLock.locked = true
    }
    Timer {
        interval: LockConfig.acquireTimeout
        running: true
        onTriggered: {
            if (!sessionLock.secure) {
                console.error("Could not acquire the session lock")
                Qt.exit(1)
            }
        }
    }
    // Status only. There is deliberately no IPC unlock, close, or toggle operation.
    IpcHandler {
        target: "sessionLock"
        function secure(): bool { return sessionLock.secure }
    }
    Process {
        id: jokes
        command: ["python3", Quickshell.shellPath("scripts/lock-joke.py")]
        running: true
        stdout: StdioCollector {
            onStreamFinished: if (text.trim()) root.joke = text.trim()
        }
    }
    Timer {
        interval: LockConfig.jokeRefreshInterval
        repeat: true
        running: true
        onTriggered: if (!jokes.running) jokes.running = true
    }
}

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config

Scope {
    id: root
    property string joke: LockConfig.fallbackJoke
    LockAuth {
        id: authentication
        onAuthenticated: {
            sessionLock.locked = false
            Qt.callLater(() => Qt.quit())
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

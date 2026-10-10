pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root
    property bool available: false
    property int count: 0
    property string severity: "green"
    property string error: ""
    property string pendingResult: ""
    property string processError: ""
    readonly property bool checking: query.running
    readonly property string script: Quickshell.env("HOME") + "/dotfiles/scripts/updates.sh"
    readonly property string installer: Quickshell.env("HOME") + "/dotfiles/scripts/installupdates.sh"
    readonly property string details: error || (checking ? "Checking for package updates…"
        : !available ? "Package updates have not been checked"
        : count === 0 ? "No updates available" : count + " package update" + (count === 1 ? "" : "s") + " available")

    function refresh() {
        if (query.running) return
        error = ""
        pendingResult = ""
        processError = ""
        query.running = true
    }
    function install() {
        if (launcher.running) return
        // Preserve Waybar's terminal and compositor placement behavior.
        const command = "alacritty -e " + "'" + installer.replace(/'/g, "'\\''") + "'"
        launcher.command = ["hyprctl", "repl", "hl.exec_cmd(" + JSON.stringify(command)
            + ", { focus_on_activate = true, float = true, center = true })"]
        launcher.running = true
    }
    Component.onCompleted: refresh()

    Process {
        id: query
        command: ["bash", root.script]
        stdout: StdioCollector { onStreamFinished: root.pendingResult = text }
        stderr: StdioCollector { onStreamFinished: root.processError = text.trim() }
        onExited: (code, status) => {
            if (code !== 0) { root.error = root.processError || "Could not check package updates."; return }
            try {
                const result = JSON.parse(root.pendingResult)
                const count = Number(result.text)
                if (!Number.isInteger(count) || count < 0 || String(result.text).trim() === "")
                    throw new Error("Invalid update count")
                root.count = count
                root.severity = result.class || "green"
                root.available = true
                console.info("Package updates:", count, "available")
            } catch (e) {
                root.error = "Could not read package update results."
                console.warn(root.error, String(e))
            }
        }
    }
    Process {
        id: launcher
        onExited: (code, status) => {
            if (code !== 0) root.error = "Could not open the package update installer."
        }
    }
    Timer {
        interval: Theme.packageUpdatesPollInterval
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../modules/clipboard/ClipboardModel.js" as ClipboardModel

Singleton {
    id: root
    property var entries: []
    property string error: ""
    property bool requestActive: false
    readonly property bool busy: requestActive
    property bool pendingRefresh: false
    property int refreshRequested: 0
    property int activeRefreshTicket: 0
    property string activeAction: ""
    property string pendingResult: ""
    signal copied()
    signal refreshed(int ticket, bool success)
    Component.onCompleted: refresh()
    function request(action: string, id: string): bool {
        if (requestActive) return false
        requestActive = true
        error = ""
        activeAction = action
        activeRefreshTicket = action === "list" ? refreshRequested : 0
        pendingResult = ""
        const script = decodeURIComponent(Qt.resolvedUrl("../scripts/clipboard.py").toString().replace(/^file:\/\//, ""))
        worker.command = ["python3", script, action, id]
        worker.running = true
        return true
    }
    function refresh(): int {
        const ticket = ++refreshRequested
        pendingRefresh = true
        drainRefresh()
        return ticket
    }
    function drainRefresh() {
        if (!pendingRefresh || requestActive) return
        pendingRefresh = false
        request("list", "")
    }
    function copy(id: string) { request("copy", id) }
    function remove(id: string) { request("delete", id) }
    function clear() { request("wipe", "") }
    Process {
        id: worker
        onExited: (code, status) => {
            const action = root.activeAction
            const ticket = root.activeRefreshTicket
            let success = false
            try {
                const result = JSON.parse(root.pendingResult)
                if (code !== 0 || result.error) root.error = result.error || "Clipboard operation failed"
                else {
                    success = true
                    if (result.copied) {
                        // Warm the cache after copying as cliphist promotes the entry.
                        root.pendingRefresh = true
                        root.copied()
                    } else {
                        const next = result.entries || []
                        if (!ClipboardModel.sameEntries(root.entries, next)) root.entries = next
                    }
                }
            } catch (error) { root.error = "Could not read clipboard history" }
            if (action === "list") root.refreshed(ticket, success)
            root.requestActive = false
            // Process.running must settle before another request starts.
            Qt.callLater(root.drainRefresh)
        }
        stdout: StdioCollector {
            onStreamFinished: root.pendingResult = text
        }
    }
}

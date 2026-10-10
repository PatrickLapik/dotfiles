pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.config

Singleton {
    id: root
    property var usage: ({})
    property bool tracking: true
    property bool ready: false
    property string error: ""
    property bool dirty: false
    Component.onCompleted: Hyprland.refreshToplevels()
    readonly property var entries: DesktopEntries.applications.values.filter(entry => !entry.noDisplay)
    readonly property var windows: Hyprland.toplevels.values.filter(window => window.lastIpcObject.mapped !== false).map(window => {
        const appId = window.lastIpcObject.class || window.lastIpcObject.initialClass || ""
        const entry = entryFor(appId)
        return {window: window, entry: entry, appId: appId, name: window.title || (entry ? entry.name : appId),
            genericName: entry ? entry.name : appId, icon: entry ? entry.icon : "", id: "window:" + window.address,
            active: window.activated, kind: "window"}
    })
    readonly property string script: decodeURIComponent(Qt.resolvedUrl("../scripts/app-history.py").toString().replace(/^file:\/\//, ""))

    function entryFor(appId: string): var {
        const alias = ShellConfig.launcherAppAliases[appId]
        return (alias ? DesktopEntries.byId(alias) : null) || DesktopEntries.heuristicLookup(appId)
            || entries.find(entry => entry.startupClass && entry.startupClass.toLowerCase() === appId.toLowerCase()) || null
    }
    function windowAddress(window: var): string {
        if (!window || !windows.some(row => row.window === window)) return ""
        const address = window.address.replace(/^0x/i, "")
        return /^[0-9a-f]+$/i.test(address) ? "0x" + address : ""
    }
    function focusWindow(window: var): bool {
        // Resolve the live handle again so closed or stale selections do nothing.
        const address = windowAddress(window)
        if (!address) return false
        Hyprland.dispatch(Hyprland.usingLua
            ? 'hl.dsp.focus({ window = "address:' + address + '" })'
            : "focuswindow address:" + address)
        const row = windows.find(value => value.window === window)
        if (row && row.entry) record(row.entry.id)
        return true
    }
    function windowsFor(id: string): var { return windows.filter(row => row.entry && row.entry.id === id) }
    function changed() { dirty = true; saveDelay.restart() }
    function record(id: string) {
        if (!ready || !tracking || !id) return
        const now = Date.now(), old = usage[id] || {count: 0, lastVisit: 0}
        const visit = now - old.lastVisit >= Theme.launcherVisitInterval
        const next = Object.assign({}, usage)
        next[id] = {lastUsed: now, lastVisit: visit ? now : old.lastVisit, count: old.count + (visit ? 1 : 0)}
        usage = next
        changed()
    }
    function boost(id: string): real {
        const item = usage[id]
        if (!item) return 0
        return Math.min(3, Math.log2(1 + item.count)) + 4 / (1 + Math.max(0, Date.now() - item.lastUsed) / 86400000)
    }
    function clearHistory() { if (ready) { usage = ({}); changed() } }
    function toggleTracking() { if (ready) { tracking = !tracking; focusDelay.stop(); changed() } }
    function launch(entry: var) {
        Quickshell.execDetached(["gtk-launch", entry.id])
        record(entry.id)
    }
    function save() {
        if (!ready || !dirty || writer.running) return
        // Prune removed apps only once the installed-app model is populated.
        if (entries.length) {
            const installed = new Set(entries.map(entry => entry.id))
            const retained = {}
            Object.keys(usage).filter(id => installed.has(id)).sort((a, b) => usage[b].lastUsed - usage[a].lastUsed)
                .slice(0, 200).forEach(id => retained[id] = usage[id])
            usage = retained
        }
        dirty = false
        writer.running = true
    }
    Connections {
        target: ToplevelManager
        function onActiveToplevelChanged() { focusDelay.restart() }
    }
    Timer {
        id: focusDelay
        interval: Theme.launcherFocusDelay
        onTriggered: {
            const window = ToplevelManager.activeToplevel
            const entry = window ? root.entryFor(window.appId) : null
            if (entry) root.record(entry.id)
        }
    }
    Timer { id: saveDelay; interval: Theme.launcherSaveDelay; onTriggered: root.save() }
    Process {
        id: reader
        command: ["python3", root.script, "read"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text)
                    if (data.error) { root.error = "Could not load app history: " + data.error; return }
                    root.usage = data.usage
                    root.tracking = data.tracking
                    root.ready = true
                    focusDelay.restart()
                } catch (_) { root.error = "Could not load app history" }
            }
        }
    }
    Process {
        id: writer
        command: ["python3", root.script, "write"]
        stdinEnabled: true
        onStarted: write(JSON.stringify({usage: root.usage, tracking: root.tracking}) + "\n")
        onExited: (code, status) => {
            if (code !== 0) { root.error = "Could not save app history"; root.dirty = true }
            else { root.error = ""; if (root.dirty) saveDelay.restart() }
        }
    }
}

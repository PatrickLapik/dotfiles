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
    property var floatingLaunches: ({})
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
    function notificationEntry(notification: var): var {
        if (!notification) return null
        const desktopId = notification.desktopEntry || ""
        const appName = notification.appName || ""
        return (desktopId ? entryFor(desktopId) : null)
            || (appName ? entryFor(appName) : null)
            || entries.find(entry => appName && entry.name.toLowerCase() === appName.toLowerCase()) || null
    }
    function openNotification(notification: var): bool {
        if (!notification) return false
        const entry = notificationEntry(notification)
        const appName = (notification.appName || "").toLowerCase()
        const matches = entry ? windowsFor(entry.id) : windows.filter(row => appName && row.appId.toLowerCase() === appName)
        const existing = matches.find(row => row.active) || matches[0]
        if (existing && focusWindow(existing.window)) return true
        if (!entry) return false
        launch(entry, true)
        return true
    }
    function openScreenshot(path: string) {
        // Quote the filename for exec_cmd's shell, then quote that command for Lua.
        const command = "loupe '" + path.replace(/'/g, "'\\''") + "'"
        Hyprland.dispatch(Hyprland.usingLua
            ? "hl.dsp.exec_cmd(" + JSON.stringify(command)
                + ', { float = true, center = true, size = { "(monitor_w*0.5)", "(monitor_h*0.5)" } })'
            : "exec [float; center; size 50% 50%] " + command)
    }
    function floatLaunchedWindows() {
        const pending = Object.assign({}, floatingLaunches)
        for (const id of Object.keys(pending)) {
            const request = pending[id]
            if (request.expires <= Date.now()) { delete pending[id]; continue }
            const row = windows.find(row => (row.entry && row.entry.id === id) || row.appId === id)
            const address = row ? windowAddress(row.window) : ""
            if (!address) continue
            Hyprland.dispatch(Hyprland.usingLua
                ? 'hl.dsp.window.float({ action = "enable", window = "address:' + address + '" })'
                : "setfloating address:" + address)
            focusWindow(row.window)
            delete pending[id]
        }
        floatingLaunches = pending
    }
    // Match the resulting window rather than a launcher PID: desktop apps may
    // activate through D-Bus or fork away from gtk-launch.
    onWindowsChanged: if (Object.keys(floatingLaunches).length) Qt.callLater(() => root.floatLaunchedWindows())
    // Class metadata can arrive after the Wayland toplevel and its title.
    // Retry while launches are pending instead of relying on a model change
    // to refresh Hyprland IPC data. Expired requests stop this timer too.
    Timer {
        interval: 100
        repeat: true
        running: Object.keys(root.floatingLaunches).length > 0
        onTriggered: {
            Hyprland.refreshToplevels()
            root.floatLaunchedWindows()
        }
    }
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
    function launch(entry, floating = false) {
        if (floating) {
            const pending = Object.assign({}, floatingLaunches)
            pending[entry.id] = {expires: Date.now() + 15000}
            floatingLaunches = pending
        }
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

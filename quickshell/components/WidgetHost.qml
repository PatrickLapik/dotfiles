import Quickshell
import Quickshell.Io
import qs.services

Scope {
    IpcHandler {
        target: "widgets"
        function open(name: string, screenName: string): void {
            if (!Widgets.open(name, screenName)) throw new Error("Unknown widget: " + name)
        }
        function toggle(name: string, screenName: string): void {
            if (!Widgets.toggle(name, screenName)) throw new Error("Unknown widget: " + name)
        }
        function close(name: string, screenName: string): void {
            if (!Widgets.close(name)) throw new Error("Unknown widget: " + name)
        }
        function list(): string { return Object.keys(Widgets.entries).sort().join("\n") }
    }
}

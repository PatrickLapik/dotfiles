import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Greetd

Item {
    id: root
    property bool preview: true
    property bool active: false
    property bool waiting: false
    property bool echoResponse: false
    property bool failed: false
    property string message: ""
    property string prompt: "Password"
    property string pendingResponse: ""
    property var session: null
    readonly property bool busy: active && !waiting
    signal focusResponse()

    function reset() {
        pendingResponse = ""
        active = false
        waiting = false
        echoResponse = false
        prompt = "Password"
    }
    function cancel() {
        const wasActive = active
        reset()
        failed = false
        message = ""
        if (!preview && wasActive) Greetd.cancelSession()
    }
    function submit(user, response, selected) {
        if (busy) return
        failed = false
        message = ""
        if (!user.trim() || !selected) {
            failed = true
            message = !user.trim() ? "Enter your username." : "No available Wayland sessions found."
            return
        }
        if (preview) {
            failed = !response.length || response === "fail"
            message = failed ? "Authentication failed. Please try again." : "Preview successful · " + selected.name
            focusResponse()
            return
        }
        if (!Greetd.available) {
            failed = true
            message = "Cannot connect to greetd."
            return
        }
        if (waiting) {
            waiting = false
            Greetd.respond(response)
            return
        }
        session = selected
        pendingResponse = response
        active = true
        Greetd.createSession(user.trim())
    }
    function power(action) {
        if (powerProcess.running) return
        failed = false
        message = ""
        if (preview) { message = action + " · preview only"; return }
        powerProcess.command = ["/usr/bin/systemctl", action === "Restart" ? "reboot" : "poweroff"]
        powerProcess.running = true
    }
    Process {
        id: powerProcess
        onExited: (code, status) => {
            if (code !== 0) {
                root.failed = true
                root.message = "Power action was denied or failed."
            }
        }
    }
    Connections {
        target: Greetd
        enabled: !root.preview
        function onAuthMessage(message, error, responseRequired, echoResponse) {
            if (!root.active) return
            if (responseRequired) {
                if (!echoResponse && root.pendingResponse.length) {
                    const response = root.pendingResponse
                    root.pendingResponse = ""
                    Greetd.respond(response)
                } else {
                    root.pendingResponse = ""
                    root.waiting = true
                    root.echoResponse = echoResponse
                    root.prompt = message || "Response"
                    root.message = ""
                    root.focusResponse()
                }
            } else {
                root.message = message
                root.failed = error
            }
        }
        function onAuthFailure(message) {
            root.reset()
            root.failed = true
            root.message = message || "Authentication failed. Please try again."
            root.focusResponse()
        }
        function onError(error) {
            root.reset()
            root.failed = true
            root.message = error || "Authentication error."
            root.focusResponse()
        }
        function onReadyToLaunch() {
            if (!root.active || !root.session) return
            root.pendingResponse = ""
            const session = root.session
            Greetd.launch(session.command, [
                "XDG_SESSION_TYPE=wayland",
                "XDG_CURRENT_DESKTOP=" + session.desktop,
                "XDG_SESSION_DESKTOP=" + session.id.replace(/\.desktop$/, "")
            ])
        }
    }
}

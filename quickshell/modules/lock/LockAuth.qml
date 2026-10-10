import QtQuick
import Quickshell
import Quickshell.Services.Pam
import qs.config

Scope {
    id: root
    readonly property bool busy: pam.active && !pam.responseRequired
    readonly property bool responseVisible: pam.active && pam.responseRequired && pam.responseVisible
    property string message: ""
    property bool failed: false
    property string pendingResponse: ""
    property bool pending: false
    signal authenticated()
    signal clearInputs()

    function submit(response: string) {
        if (busy) return
        failed = false
        message = ""
        if (pam.active && pam.responseRequired) {
            pam.respond(response)
        } else {
            pendingResponse = response
            pending = true
            if (!pam.start()) {
                pendingResponse = ""
                pending = false
                failed = true
                message = "Could not start authentication. Try again."
            }
        }
        clearInputs()
    }

    PamContext {
        id: pam
        config: LockConfig.pamService
        // Leave user unset: PAM authenticates the actual process user.
        onPamMessage: {
            if (responseRequired && root.pending && !responseVisible) {
                const response = root.pendingResponse
                root.pendingResponse = ""
                root.pending = false
                respond(response)
            } else {
                if (responseRequired) {
                    root.pendingResponse = ""
                    root.pending = false
                }
                root.message = message
                root.failed = messageIsError
            }
        }
        onCompleted: result => {
            root.pendingResponse = ""
            root.pending = false
            root.clearInputs()
            if (result === PamResult.Success) {
                root.authenticated()
            } else {
                root.failed = true
                root.message = result === PamResult.Error
                    ? "Authentication unavailable. Try again."
                    : "Authentication failed. Please try again."
            }
        }
    }
}

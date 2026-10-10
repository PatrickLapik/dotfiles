import Quickshell
import qs.components
import qs.services

Scope {
    WidgetEndpoint {
        name: "lock"
        openAction: screenName => {
            Widgets.screenFor(screenName)
            Quickshell.execDetached(["python3", Quickshell.shellPath("scripts/lock.py")])
            Widgets.closed("lock")
        }
        // Closing other widgets must never unlock the session.
        closeAction: () => Widgets.closed("lock")
    }
}

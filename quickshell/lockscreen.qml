import Quickshell
import qs.modules.lock

// Separate process: regular shell reloads cannot interrupt a locked session.
ShellRoot {
    LockScreen {}
}

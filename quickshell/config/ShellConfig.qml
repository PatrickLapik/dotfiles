pragma Singleton
import Quickshell

Singleton {
    // auto detects an internal battery; laptop/desktop override the detection.
    readonly property string deviceType: "auto"
    readonly property real volumeStep: 0.05
}

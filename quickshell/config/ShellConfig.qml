pragma Singleton
import Quickshell

Singleton {
    // Multiplies logical UI dimensions on top of compositor output scaling.
    readonly property real uiScale: 1
    readonly property real effectiveUiScale: Number.isFinite(uiScale) && uiScale > 0 ? uiScale : 1.0
    function scaled(value: real): int { return Math.round(value * effectiveUiScale) }

    // Optional window app ID -> desktop entry ID overrides.
    readonly property var launcherAppAliases: ({})

    // auto detects an internal battery; laptop/desktop override the detection.
    readonly property string deviceType: "auto"
    // Set to true to hide the topbar until the pointer reaches the screen edge.
    readonly property bool barAutoHide: false
    // Default for axes omitted from Sizing.popupLimits; explicit rules take priority.
    readonly property bool popupHugContents: true
    readonly property real volumeStep: 0.05
}

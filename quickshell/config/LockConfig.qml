pragma Singleton
import Quickshell

Singleton {
    // Uses the same system authentication policy as the existing Hyprlock setup.
    readonly property string pamService: "hyprlock"
    readonly property int acquireTimeout: 4000
    readonly property int jokeRefreshInterval: 60000
    readonly property string fallbackJoke: "Chuck Norris can divide by zero."
    readonly property real backgroundDim: 0.62
    readonly property real backgroundBlur: 0.8
}

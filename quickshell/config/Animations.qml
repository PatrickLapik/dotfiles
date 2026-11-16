pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property int marqueePause: 1200
    readonly property real marqueePixelsPerSecond: 30
    // Set false for instant transitions. Durations are milliseconds.
    readonly property bool enabled: true
    readonly property int revealDuration: 140
    readonly property int revealEasing: Easing.OutCubic
    readonly property int expandDuration: 160
    readonly property int collapseDuration: 200
    readonly property int expandEasing: Easing.OutCubic
    readonly property int collapseEasing: Easing.OutCubic
    // Opacity needs a steady fade rather than the fast initial jump of motion.
    readonly property int fadeInDuration: 160
    readonly property int fadeOutDuration: 120
    readonly property int fadeEasing: Easing.Linear
    readonly property int notificationClearStagger: 70
    // How popups appear (bar dropdowns, centered popups, OSD indicators):
    //   "unfold"  surface uncovers content in place
    //   "drawer"  surface slides out from under its edge, content riding along
    //   "zoom"    grows from its anchor with a slight spring; content scales/fades in
    //   "cascade" surface unfolds, then content fades in and rises into place
    readonly property string revealStyle: "cascade"
    readonly property int popupOpenDuration: revealStyle === "zoom" || revealStyle === "cascade" ? 240
        : revealStyle === "drawer" ? 200 : expandDuration
    readonly property int popupOpenEasing: revealStyle === "zoom" ? Easing.OutBack : expandEasing
    readonly property real popupOpenOvershoot: 1.1
    readonly property real cascadeContentStart: 0.3
    readonly property int feedbackDuration: 80
    readonly property int feedbackEasing: Easing.OutCubic
}

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
    readonly property int feedbackDuration: 80
    readonly property int feedbackEasing: Easing.OutCubic
}

pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property int marqueePause: 1200
    readonly property real marqueePixelsPerSecond: 30
    // Set false for instant transitions. Durations are milliseconds.
    readonly property bool enabled: true
    readonly property int revealDuration: 160
    readonly property int revealEasing: Easing.OutCubic
    readonly property int expandDuration: 180
    readonly property int collapseDuration: 130
    readonly property int expandEasing: Easing.OutCubic
    readonly property int collapseEasing: Easing.InOutQuad
    readonly property int feedbackDuration: 100
    readonly property int feedbackEasing: Easing.OutCubic
}

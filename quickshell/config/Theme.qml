pragma Singleton

import QtQuick
import Quickshell

Singleton {
    // Layout dimensions remain in Spacing and Sizing.
    readonly property string fontFamily: "sans-serif"
    readonly property int fontSizeSmall: 12
    readonly property int fontSize: 14
    readonly property int fontSizeLarge: 18

    readonly property int radiusSmall: 6
    readonly property int radius: 12
    readonly property int radiusLarge: 20

    readonly property int durationFast: 100
    readonly property int duration: 180
    readonly property int durationSlow: 300
    readonly property int wallpaperTransitionDuration: 700
    readonly property int easing: Easing.OutCubic
    readonly property real panelOpacity: 0.9
}

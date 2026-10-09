pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property real mediaArtworkOpacity: 0.18
    readonly property real scrollBarOpacity: 0.55
    readonly property int clipboardPollInterval: 2000
    readonly property int notificationTimeout: 5000
    // Layout dimensions remain in Spacing and Sizing.
    // Disable to return to the live Matugen palette and softer surfaces.
    readonly property bool metalStyle: false
    readonly property string fontFamily: "Adwaita Sans"
    readonly property string headingFontFamily: fontFamily
    readonly property real headingLetterSpacing: 0
    readonly property real buttonLetterSpacing: 0
    readonly property real surfaceTextureOpacity: metalStyle ? 0.18 : 0
    readonly property int fontWeight: Font.Normal
    readonly property int controlFontWeight: Font.Medium
    readonly property int headingFontWeight: Font.DemiBold
    readonly property int emphasisFontWeight: Font.DemiBold
    readonly property int fontSizeSmall: 14
    readonly property int fontSize: 12
    readonly property int fontSizeLarge: 16
    readonly property int headingLineHeight: 28
    readonly property int clockExpandedFontSize: 42
    readonly property real iconStrokeWidth: 1.5
    readonly property real inactiveCalendarOpacity: 0.45

    readonly property int borderNone: 0
    readonly property int borderWidth: 1
    readonly property int borderSelectedWidth: 2

    readonly property int radiusNone: 0
    readonly property int radiusWorkspace: metalStyle ? 1 : 4
    readonly property int radiusSmall: metalStyle ? 2 : 8
    readonly property int radius: metalStyle ? 3 : 16
    readonly property int radiusLarge: radius

    readonly property int durationFast: 100
    readonly property int duration: 180
    readonly property int durationSlow: 300
    readonly property int barHideDelay: 300
    readonly property int pointerPollInterval: 100
    readonly property int brightnessPollInterval: 3000
    readonly property int wallpaperTransitionDuration: 700
    readonly property int easing: Easing.OutCubic
    readonly property real panelOpacity: 0.97
    readonly property color containerHighlightColor: "#c5d0d2"
    readonly property real containerHighlightOpacity: metalStyle ? 0.045 : 0.025
    readonly property real containerHighlightFadeEnd: 0.55
}

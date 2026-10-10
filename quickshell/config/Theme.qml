pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property int lockClockFontSize: ShellConfig.scaled(76)
    readonly property int lockUserFontSize: ShellConfig.scaled(24)
    readonly property real mediaArtworkOpacity: 0.18
    readonly property real scrollBarOpacity: 0.4
    readonly property int clipboardPollInterval: 2000
    readonly property int notificationTimeout: 5000
    readonly property int notificationProgressInterval: 33
    readonly property int networkConnectionTimeout: 45000
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
    readonly property int fontSizeSmall: ShellConfig.scaled(14)
    readonly property int fontSize: ShellConfig.scaled(12)
    readonly property int fontSizeLarge: ShellConfig.scaled(16)
    readonly property int headingLineHeight: ShellConfig.scaled(28)
    readonly property int clockExpandedFontSize: ShellConfig.scaled(42)
    readonly property real iconStrokeWidth: 1.5 * ShellConfig.effectiveUiScale
    readonly property real inactiveCalendarOpacity: 0.45

    readonly property int borderNone: 0
    readonly property int borderWidth: ShellConfig.scaled(1)
    readonly property int borderSelectedWidth: ShellConfig.scaled(2)

    readonly property int radiusNone: 0
    readonly property int radiusWorkspace: ShellConfig.scaled(metalStyle ? 1 : 4)
    readonly property int radiusSmall: ShellConfig.scaled(metalStyle ? 2 : 8)
    readonly property int radius: ShellConfig.scaled(metalStyle ? 3 : 16)
    readonly property int radiusLarge: radius

    readonly property int durationFast: 100
    readonly property int duration: 180
    readonly property int durationSlow: 300
    readonly property int barHideDelay: 300
    readonly property int pointerPollInterval: 100
    readonly property int brightnessPollInterval: 3000
    readonly property int wallpaperTransitionDuration: 700
    readonly property int easing: Easing.OutCubic
    readonly property real panelOpacity: 0.6
    readonly property color containerHighlightColor: "#c5d0d2"
    readonly property real containerHighlightOpacity: metalStyle ? 0.045 : 0.1
    readonly property real containerHighlightFadeEnd: 0.55
}

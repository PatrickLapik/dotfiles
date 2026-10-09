pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Runtime output belongs outside the source tree.
    readonly property string palettePath: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/quickshell/colors.json"
    readonly property bool loaded: paletteFile.loaded

    FileView {
        id: paletteFile
        path: root.palettePath
        watchChanges: true
        onFileChanged: reload()
        // A missing file is normal before the first Matugen run.
        onLoadFailed: error => {
            if (error !== FileViewError.FileNotFound)
                console.warn("Could not load theme palette:", error)
        }
        printErrors: false

        JsonAdapter {
            id: palette
            property string primary: "#D0BCFF"
            property string on_primary: "#381E72"
            property string primary_container: "#4F378B"
            property string on_primary_container: "#EADDFF"
            property string secondary: "#CCC2DC"
            property string on_secondary: "#332D41"
            property string secondary_container: "#4A4458"
            property string on_secondary_container: "#E8DEF8"
            property string tertiary: "#EFB8C8"
            property string on_tertiary: "#492532"
            property string tertiary_container: "#633B48"
            property string on_tertiary_container: "#FFD8E4"
            property string error: "#F2B8B5"
            property string on_error: "#601410"
            property string error_container: "#8C1D18"
            property string on_error_container: "#F9DEDC"
            property string background: "#141218"
            property string on_background: "#E6E0E9"
            property string surface: "#141218"
            property string on_surface: "#E6E0E9"
            property string surface_variant: "#49454F"
            property string on_surface_variant: "#CAC4D0"
            property string surface_dim: "#141218"
            property string surface_bright: "#3B383E"
            property string surface_container_lowest: "#0F0D13"
            property string surface_container_low: "#1D1B20"
            property string surface_container: "#211F26"
            property string surface_container_high: "#2B2930"
            property string surface_container_highest: "#36343B"
            property string outline: "#938F99"
            property string outline_variant: "#49454F"
            property string inverse_surface: "#E6E0E9"
            property string inverse_on_surface: "#322F35"
            property string inverse_primary: "#6750A4"
            property string scrim: "#000000"
            property string shadow: "#000000"
        }
    }

    // Material roles; pair each fill with its matching on* text color.
    readonly property color primary: palette.primary
    readonly property color onPrimary: palette.on_primary
    readonly property color primaryContainer: palette.primary_container
    readonly property color onPrimaryContainer: palette.on_primary_container
    readonly property color secondary: palette.secondary
    readonly property color onSecondary: palette.on_secondary
    readonly property color secondaryContainer: palette.secondary_container
    readonly property color onSecondaryContainer: palette.on_secondary_container
    readonly property color tertiary: palette.tertiary
    readonly property color onTertiary: palette.on_tertiary
    readonly property color tertiaryContainer: palette.tertiary_container
    readonly property color onTertiaryContainer: palette.on_tertiary_container
    readonly property color error: palette.error
    readonly property color onError: palette.on_error
    readonly property color errorContainer: palette.error_container
    readonly property color onErrorContainer: palette.on_error_container
    readonly property color background: palette.background
    readonly property color onBackground: palette.on_background
    readonly property color surface: palette.surface
    readonly property color onSurface: palette.on_surface
    readonly property color surfaceVariant: palette.surface_variant
    readonly property color onSurfaceVariant: palette.on_surface_variant
    readonly property color surfaceDim: palette.surface_dim
    readonly property color surfaceBright: palette.surface_bright
    readonly property color surfaceContainerLowest: palette.surface_container_lowest
    readonly property color surfaceContainerLow: palette.surface_container_low
    readonly property color surfaceContainer: palette.surface_container
    readonly property color surfaceContainerHigh: palette.surface_container_high
    readonly property color surfaceContainerHighest: palette.surface_container_highest
    readonly property color outline: palette.outline
    readonly property color outlineVariant: palette.outline_variant
    readonly property color inverseSurface: palette.inverse_surface
    readonly property color inverseOnSurface: palette.inverse_on_surface
    readonly property color inversePrimary: palette.inverse_primary
    readonly property color scrim: palette.scrim
    readonly property color shadow: palette.shadow

    // Compatibility aliases and common shell semantics.
    readonly property color foreground: onSurface
    readonly property color accent: primary
    readonly property color success: tertiary
    readonly property color panel: surfaceContainer
    readonly property color text: onSurface
    readonly property color textMuted: onSurfaceVariant
    readonly property color border: outlineVariant
    readonly property color temp: withAlpha(surface, 0.8)

    function withAlpha(value: color, opacity: real): color {
        return Qt.rgba(value.r, value.g, value.b, Math.max(0, Math.min(1, opacity)))
    }
}

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

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

    // Cold iron and bone-silver roles; Matugen remains available via Theme.metalStyle.
    readonly property var metalPalette: ({
        primary: "#bcc9cb",
        on_primary: "#101719",
        primary_container: "#303e42",
        on_primary_container: "#e4ebea",
        secondary: "#a9b5b5",
        on_secondary: "#151c1d",
        secondary_container: "#293335",
        on_secondary_container: "#dde3e1",
        tertiary: "#b7baaa",
        on_tertiary: "#1c201a",
        tertiary_container: "#343a30",
        on_tertiary_container: "#e0e3d6",
        error: "#df9991",
        on_error: "#301310",
        error_container: "#4b2825",
        on_error_container: "#ffdad4",
        background: "#080b0d",
        on_background: "#d9dfdd",
        surface: "#0e1214",
        on_surface: "#d9dfdd",
        surface_variant: "#30393c",
        on_surface_variant: "#a2adae",
        surface_dim: "#080b0d",
        surface_bright: "#384144",
        surface_container_lowest: "#080b0d",
        surface_container_low: "#111719",
        surface_container: "#181f22",
        surface_container_high: "#222b2e",
        surface_container_highest: "#303b3e",
        outline: "#77878a",
        outline_variant: "#465357",
        inverse_surface: "#d9dfdd",
        inverse_on_surface: "#1c2528",
        inverse_primary: "#41575e",
        scrim: "#000000",
        shadow: "#000000"
    })

    // Material roles; pair each fill with its matching on* text color.
    // Aliases avoid QML treating dynamic on* initializers as signal handlers.
    readonly property color primary: Theme.metalStyle ? metalPalette.primary : palette.primary
    readonly property color primaryText: Theme.metalStyle ? metalPalette.on_primary : palette.on_primary
    readonly property alias onPrimary: root.primaryText
    readonly property color primaryContainer: Theme.metalStyle ? metalPalette.primary_container : palette.primary_container
    readonly property color primaryContainerText: Theme.metalStyle ? metalPalette.on_primary_container : palette.on_primary_container
    readonly property alias onPrimaryContainer: root.primaryContainerText
    readonly property color secondary: Theme.metalStyle ? metalPalette.secondary : palette.secondary
    readonly property color secondaryText: Theme.metalStyle ? metalPalette.on_secondary : palette.on_secondary
    readonly property alias onSecondary: root.secondaryText
    readonly property color secondaryContainer: Theme.metalStyle ? metalPalette.secondary_container : palette.secondary_container
    readonly property color secondaryContainerText: Theme.metalStyle ? metalPalette.on_secondary_container : palette.on_secondary_container
    readonly property alias onSecondaryContainer: root.secondaryContainerText
    readonly property color tertiary: Theme.metalStyle ? metalPalette.tertiary : palette.tertiary
    readonly property color tertiaryText: Theme.metalStyle ? metalPalette.on_tertiary : palette.on_tertiary
    readonly property alias onTertiary: root.tertiaryText
    readonly property color tertiaryContainer: Theme.metalStyle ? metalPalette.tertiary_container : palette.tertiary_container
    readonly property color tertiaryContainerText: Theme.metalStyle ? metalPalette.on_tertiary_container : palette.on_tertiary_container
    readonly property alias onTertiaryContainer: root.tertiaryContainerText
    readonly property color error: Theme.metalStyle ? metalPalette.error : palette.error
    readonly property color errorText: Theme.metalStyle ? metalPalette.on_error : palette.on_error
    readonly property alias onError: root.errorText
    readonly property color errorContainer: Theme.metalStyle ? metalPalette.error_container : palette.error_container
    readonly property color errorContainerText: Theme.metalStyle ? metalPalette.on_error_container : palette.on_error_container
    readonly property alias onErrorContainer: root.errorContainerText
    readonly property color background: Theme.metalStyle ? metalPalette.background : palette.background
    readonly property color backgroundText: Theme.metalStyle ? metalPalette.on_background : palette.on_background
    readonly property alias onBackground: root.backgroundText
    readonly property color surface: Theme.metalStyle ? metalPalette.surface : palette.surface
    readonly property color surfaceText: Theme.metalStyle ? metalPalette.on_surface : palette.on_surface
    readonly property alias onSurface: root.surfaceText
    readonly property color surfaceVariant: Theme.metalStyle ? metalPalette.surface_variant : palette.surface_variant
    readonly property color surfaceVariantText: Theme.metalStyle ? metalPalette.on_surface_variant : palette.on_surface_variant
    readonly property alias onSurfaceVariant: root.surfaceVariantText
    readonly property color surfaceDim: Theme.metalStyle ? metalPalette.surface_dim : palette.surface_dim
    readonly property color surfaceBright: Theme.metalStyle ? metalPalette.surface_bright : palette.surface_bright
    readonly property color surfaceContainerLowest: Theme.metalStyle ? metalPalette.surface_container_lowest : palette.surface_container_lowest
    readonly property color surfaceContainerLow: Theme.metalStyle ? metalPalette.surface_container_low : palette.surface_container_low
    readonly property color surfaceContainer: Theme.metalStyle ? metalPalette.surface_container : palette.surface_container
    readonly property color surfaceContainerHigh: Theme.metalStyle ? metalPalette.surface_container_high : palette.surface_container_high
    readonly property color surfaceContainerHighest: Theme.metalStyle ? metalPalette.surface_container_highest : palette.surface_container_highest
    readonly property color outline: Theme.metalStyle ? metalPalette.outline : palette.outline
    readonly property color outlineVariant: Theme.metalStyle ? metalPalette.outline_variant : palette.outline_variant
    readonly property color inverseSurface: Theme.metalStyle ? metalPalette.inverse_surface : palette.inverse_surface
    readonly property color inverseOnSurface: Theme.metalStyle ? metalPalette.inverse_on_surface : palette.inverse_on_surface
    readonly property color inversePrimary: Theme.metalStyle ? metalPalette.inverse_primary : palette.inverse_primary
    readonly property color scrim: Theme.metalStyle ? metalPalette.scrim : palette.scrim
    readonly property color shadow: Theme.metalStyle ? metalPalette.shadow : palette.shadow

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

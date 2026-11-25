import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.config
import "../assets/lucide/bounds.js" as IconBounds

Item {
    id: root
    property string kind: "volume"
    property color tint: Colors.text
    property real batteryLevel: 100
    // Quickshell reports Wi-Fi strength as a fraction (0–1).
    property real wifiStrength: 1
    readonly property real wifiFraction: Number.isFinite(wifiStrength) ? Math.max(0, Math.min(1, wifiStrength)) : 0
    readonly property bool isBattery: kind === "battery" || kind === "charging"
    readonly property real batteryFraction: Number.isFinite(batteryLevel) ? Math.max(0, Math.min(100, batteryLevel)) / 100 : 0
    readonly property color batteryFill: batteryFraction <= Theme.batteryLowThreshold / 100 ? Theme.batteryLowColor
        : batteryFraction <= Theme.batteryWarningThreshold / 100 ? Theme.batteryWarningColor : Theme.batteryHealthyColor
    property bool hugContents: true
    readonly property real effectiveStrokeWidth: Number.isFinite(strokeWidth) ? Math.max(0.1, strokeWidth) : 1.8
    // Include the custom strike-throughs in the composite artwork bounds.
    readonly property var artworkBounds: kind === "muted" ? [2, 22]
        : kind === "bluetooth-off" ? [6, 18] : IconBounds.bounds[iconName] || [0, 24]
    readonly property real cropLeft: hugContents ? Math.max(0, artworkBounds[0] - effectiveStrokeWidth / 2) : 0
    readonly property real cropRight: hugContents ? Math.min(24, artworkBounds[1] + effectiveStrokeWidth / 2) : 24
    readonly property real viewBoxWidth: Math.max(1, cropRight - cropLeft)
    implicitWidth: implicitHeight * viewBoxWidth / 24
    implicitHeight: Sizing.barIconSize

    // Width is in Lucide's 24-unit viewBox; it scales naturally with icon size.
    property real strokeWidth: Theme.iconStrokeWidth
    readonly property var iconNames: ({
        "volume": "volume-2",
        "volume-low": "volume-1",
        "muted": "volume-x",
        "microphone": "mic",
        "microphone-muted": "mic-off",
        "wifi": "wifi",
        "offline": "wifi-off",
        "ethernet": "ethernet-port",
        "bluetooth": "bluetooth",
        "bluetooth-off": "bluetooth",
        "bell": "bell",
        "bell-off": "bell-off",
        "bell-dot": "bell-dot",
        "bell-off-dot": "bell-off",
        "package": "package",
        "wallpaper": "wallpaper",
        "application": "panels-top-left",
        "music": "music",
        "play": "play",
        "pause": "pause",
        "previous": "skip-back",
        "next": "skip-forward",
        "lock": "lock",
        "logout": "log-out",
        "suspend": "moon",
        "restart": "rotate-cw",
        "power": "power",
        "sun": "sun",
        "chevron-left": "chevron-left",
        "chevron-right": "chevron-right",
        "chevron-down": "chevron-down",
        "chevron-up": "chevron-up",
        "check": "check",
        "close": "x",
        "trash": "trash"
    })
    readonly property string iconName: {
        // Keep the same outline and bounds at every charge level, including charging.
        if (isBattery) return "battery"
        return iconNames[kind] || "circle-question-mark"
    }

    FileView {
        id: svgFile
        path: Qt.resolvedUrl("../assets/lucide/" + root.iconName + ".svg")
        blockLoading: true
    }
    Image {
        anchors.fill: parent
        source: {
            let svg = svgFile.text()
            if (!svg) return ""
            const color = Qt.rgba(root.tint.r, root.tint.g, root.tint.b, 1).toString()
            const stroke = root.effectiveStrokeWidth
            svg = svg.replace(/stroke-width="[^"]*"/g, 'stroke-width="' + stroke + '"')
            if (root.kind === "muted" || root.kind === "bluetooth-off") {
                const volume = root.kind === "muted"
                // Center the speaker body (x=2..11) at x=12 before adding its slash.
                if (volume) svg = svg.replace(/<path d="m16\.5 [^"]*"\s*\/>/g, "")
                // A steeper Bluetooth slash stays distinct from its diagonal arms.
                const slash = volume ? "M2 2 22 22" : "M6 2 18 22"
                const transform = volume ? ' transform="translate(5.5 0)"' : ""
                // Clear a transparent gap behind the slash, rather than merging
                // it into the glyph or painting a surface-colored halo.
                svg = svg.replace(/(<svg\b[^>]*>)([\s\S]*)(<\/svg>)/,
                    '$1<defs><mask id="off-slash" maskUnits="userSpaceOnUse" x="0" y="0" width="24" height="24">'
                    + '<rect width="24" height="24" fill="white" stroke="none"/>'
                    + '<path d="' + slash + '" stroke="black" stroke-width="' + (stroke + 2) + '"/>'
                    + '</mask></defs><g mask="url(#off-slash)"><g' + transform + '>$2</g></g>'
                    + '<path d="' + slash + '"/>$3')
            }
            if (root.kind === "wifi") {
                // Lucide path order: dot, outer arc, middle arc, inner arc.
                // Retain dim arcs so signal changes never alter the icon bounds.
                const thresholds = [0, 0.75, 0.5, 0.25]
                let pathIndex = 0
                svg = svg.replace(/<path\b[^>]*\/>/g, path => {
                    const index = pathIndex++
                    return index === 0 || root.wifiFraction > thresholds[index] ? path
                        : path.replace("/>", ' opacity="' + Theme.wifiInactiveArcOpacity + '"/>')
                })
            }
            if (root.isBattery) {
                // Drawing coordinates use Lucide's 24-unit viewBox. The interior
                // fills continuously from empty to full, inset from the outline.
                const fill = '<rect x="4" y="8" width="' + (12 * root.batteryFraction)
                    + '" height="8" stroke="none" fill="' + root.batteryFill.toString() + '"/>'
                // A contrasting halo keeps the bolt readable over any fill level.
                const bolt = root.kind === "charging"
                    ? '<path d="m11 7-3 5h4l-3 5" stroke="' + Colors.surface.toString()
                        + '" stroke-width="' + (stroke + 2) + '"/>'
                        + '<path d="m11 7-3 5h4l-3 5" stroke="' + color + '"/>'
                    : ""
                svg = svg.replace("</svg>", fill + bolt + "</svg>")
            }
            return "data:image/svg+xml," + encodeURIComponent(svg
                .replace(/viewBox="[^"]*"/, 'viewBox="' + root.cropLeft + ' 0 ' + root.viewBoxWidth + ' 24"')
                .replace(/width="24"/, 'width="' + root.viewBoxWidth + '"')
                .replace(/stroke="currentColor"/g, 'stroke="' + color + '"'))
        }
        sourceSize.width: Math.max(1, Math.ceil(width))
        sourceSize.height: Math.max(1, Math.ceil(height))
        fillMode: Image.PreserveAspectFit
        opacity: root.tint.a
    }

    // Unread indicator is a drawing primitive over the symbolic bell.
    Rectangle {
        visible: root.kind === "bell-off-dot"
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Spacing.iconBadgeInset
        width: Sizing.iconBadgeSize
        height: width
        radius: width / 2
        color: root.tint
    }
}

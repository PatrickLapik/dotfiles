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
    property bool hugContents: true
    readonly property real effectiveStrokeWidth: Number.isFinite(strokeWidth) ? Math.max(0.1, strokeWidth) : 1.8
    readonly property var artworkBounds: IconBounds.bounds[iconName] || [0, 24]
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
        "bluetooth-off": "bluetooth-off",
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
        if (kind === "charging") return "battery-charging"
        if (kind === "battery") {
            const level = Number.isFinite(batteryLevel) ? batteryLevel : 100
            return level <= 10 ? "battery" : level <= 30 ? "battery-low"
                 : level <= 70 ? "battery-medium" : "battery-full"
        }
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
            const svg = svgFile.text()
            if (!svg) return ""
            const color = Qt.rgba(root.tint.r, root.tint.g, root.tint.b, 1).toString()
            const stroke = root.effectiveStrokeWidth
            return "data:image/svg+xml," + encodeURIComponent(svg
                .replace(/viewBox="[^"]*"/, 'viewBox="' + root.cropLeft + ' 0 ' + root.viewBoxWidth + ' 24"')
                .replace(/width="24"/, 'width="' + root.viewBoxWidth + '"')
                .replace(/stroke="currentColor"/g, 'stroke="' + color + '"')
                .replace(/stroke-width="[^"]*"/g, 'stroke-width="' + stroke + '"'))
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

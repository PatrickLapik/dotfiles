import QtQuick
import qs.services
import qs.config

Canvas {
    id: root
    property string kind: "volume"
    property color tint: Colors.text
    implicitWidth: Sizing.barIconSize
    implicitHeight: Sizing.barIconSize
    onKindChanged: requestPaint()
    onTintChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
        const c = getContext("2d")
        c.reset()
        c.scale(width / 20, height / 20)
        c.strokeStyle = tint
        c.fillStyle = tint
        c.lineWidth = Theme.iconStrokeWidth
        c.lineCap = "round"
        c.lineJoin = "round"
        function line(x, y, a, b) { c.beginPath(); c.moveTo(x, y); c.lineTo(a, b); c.stroke() }
        if (kind === "wifi" || kind === "offline") {
            for (let r = 5; r <= 11; r += 3) {
                c.beginPath(); c.arc(10, 16, r, Math.PI * 1.23, Math.PI * 1.77); c.stroke()
            }
            c.beginPath(); c.arc(10, 16, 1, 0, Math.PI * 2); c.fill()
            if (kind === "offline") line(3, 3, 17, 17)
        } else if (kind === "microphone" || kind === "microphone-muted") {
            c.beginPath(); c.moveTo(7, 5); c.bezierCurveTo(7, 1, 13, 1, 13, 5); c.lineTo(13, 10); c.bezierCurveTo(13, 14, 7, 14, 7, 10); c.closePath(); c.stroke()
            c.beginPath(); c.moveTo(4, 9); c.lineTo(4, 10); c.bezierCurveTo(4, 18, 16, 18, 16, 10); c.lineTo(16, 9); c.stroke()
            line(10, 16, 10, 19); line(6, 19, 14, 19)
            if (kind === "microphone-muted") line(2, 2, 18, 18)
        } else if (kind === "ethernet") {
            c.strokeRect(3, 3, 14, 10)
            line(10, 13, 10, 17); line(5, 17, 15, 17)
            for (let x = 6; x <= 14; x += 4) line(x, 6, x, 9)
        } else if (kind === "battery" || kind === "charging") {
            c.strokeRect(2, 5, 15, 10); c.fillRect(18, 8, 1.5, 4)
            if (kind === "charging") {
                c.beginPath(); c.moveTo(11, 6); c.lineTo(7, 10); c.lineTo(11, 10); c.lineTo(8, 14); c.stroke()
            } else c.fillRect(4, 7, 9, 6)
        } else if (kind === "bell" || kind === "bell-off" || kind === "bell-dot" || kind === "bell-off-dot") {
            c.beginPath(); c.moveTo(4, 14); c.lineTo(5, 12); c.lineTo(5, 8);
            c.bezierCurveTo(5, 1, 15, 1, 15, 8); c.lineTo(15, 12); c.lineTo(16, 14); c.closePath(); c.stroke()
            c.beginPath(); c.arc(10, 15, 2, 0, Math.PI); c.stroke()
            if (kind === "bell-off" || kind === "bell-off-dot") line(2, 2, 18, 18)
            if (kind === "bell-dot" || kind === "bell-off-dot") {
                c.beginPath(); c.arc(17, 3, 2, 0, Math.PI * 2); c.fill()
            }
        } else if (kind === "wallpaper") {
            c.strokeRect(2, 3, 16, 14)
            c.beginPath(); c.moveTo(3, 15); c.lineTo(8, 9); c.lineTo(12, 13); c.lineTo(15, 10); c.lineTo(18, 14); c.stroke()
            c.beginPath(); c.arc(13, 7, 1.2, 0, Math.PI * 2); c.fill()
        } else if (kind === "application") {
            c.strokeRect(2, 3, 16, 14); line(2, 7, 18, 7)
            line(5, 5, 5.5, 5); line(8, 5, 8.5, 5)
        } else if (kind === "music") {
            c.beginPath(); c.moveTo(7, 14); c.lineTo(7, 5); c.lineTo(16, 3); c.lineTo(16, 12); c.stroke()
            line(7, 8, 16, 6)
            c.beginPath(); c.ellipse(2, 13, 5, 4); c.fill()
            c.beginPath(); c.ellipse(11, 11, 5, 4); c.fill()
        } else if (kind === "play") {
            c.beginPath(); c.moveTo(6, 3); c.lineTo(16, 10); c.lineTo(6, 17); c.closePath(); c.stroke()
        } else if (kind === "pause") {
            c.strokeRect(5, 3, 3, 14); c.strokeRect(12, 3, 3, 14)
        } else if (kind === "previous" || kind === "next") {
            const previous = kind === "previous"
            line(previous ? 4 : 16, 4, previous ? 4 : 16, 16)
            c.beginPath(); c.moveTo(previous ? 15 : 5, 4); c.lineTo(previous ? 6 : 14, 10); c.lineTo(previous ? 15 : 5, 16); c.closePath(); c.stroke()
        } else if (kind === "lock") {
            c.beginPath(); c.arc(10, 8, 4, Math.PI, 0); c.stroke()
            c.strokeRect(4, 8, 12, 9); line(10, 11, 10, 14)
        } else if (kind === "logout") {
            c.beginPath(); c.moveTo(8, 3); c.lineTo(3, 3); c.lineTo(3, 17); c.lineTo(8, 17); c.stroke()
            line(8, 10, 18, 10); line(14, 6, 18, 10); line(14, 14, 18, 10)
        } else if (kind === "suspend") {
            c.beginPath(); c.moveTo(12, 2); c.bezierCurveTo(0, 0, 0, 19, 13, 17); c.bezierCurveTo(16, 16, 18, 13, 18, 10); c.bezierCurveTo(10, 13, 7, 6, 12, 2); c.closePath(); c.stroke()
        } else if (kind === "restart") {
            // Open circular arrow with a connected, clockwise arrowhead.
            c.beginPath(); c.arc(10, 10, 7, 0.15, Math.PI * 1.75); c.lineTo(17, 7); c.stroke()
            c.beginPath(); c.moveTo(12, 7); c.lineTo(17, 7); c.lineTo(17, 2); c.stroke()
        } else if (kind === "power") {
            c.beginPath(); c.arc(10, 11, 7, -0.95, Math.PI + 0.95); c.stroke()
            line(10, 2, 10, 10)
        } else if (kind === "sun") {
            c.beginPath(); c.arc(10, 10, 3.5, 0, Math.PI * 2); c.stroke()
            for (let i = 0; i < 8; i++) {
                const a = i * Math.PI / 4
                line(10 + Math.cos(a) * 6, 10 + Math.sin(a) * 6, 10 + Math.cos(a) * 8.5, 10 + Math.sin(a) * 8.5)
            }
        } else if (kind === "chevron-left" || kind === "chevron-right" || kind === "chevron-down" || kind === "chevron-up") {
            c.beginPath()
            if (kind === "chevron-left") { c.moveTo(12, 5); c.lineTo(7, 10); c.lineTo(12, 15) }
            else if (kind === "chevron-right") { c.moveTo(8, 5); c.lineTo(13, 10); c.lineTo(8, 15) }
            else if (kind === "chevron-down") { c.moveTo(5, 8); c.lineTo(10, 13); c.lineTo(15, 8) }
            else { c.moveTo(5, 12); c.lineTo(10, 7); c.lineTo(15, 12) }
            c.stroke()
        } else if (kind === "check") {
            c.beginPath(); c.moveTo(4, 10); c.lineTo(8, 14); c.lineTo(16, 5); c.stroke()
        } else if (kind === "close") {
            line(5, 5, 15, 15); line(15, 5, 5, 15)
        } else if (kind === "trash") {
            line(3, 5, 17, 5); line(7, 2, 13, 2)
            c.beginPath(); c.moveTo(5, 5); c.lineTo(6, 17); c.lineTo(14, 17); c.lineTo(15, 5); c.stroke()
            line(8, 8, 8, 14); line(12, 8, 12, 14)
        } else {
            c.beginPath(); c.moveTo(2, 8); c.lineTo(6, 8); c.lineTo(10, 4); c.lineTo(10, 16); c.lineTo(6, 12); c.lineTo(2, 12); c.closePath(); c.stroke()
            if (kind === "muted") {
                line(14, 7, 18, 13); line(18, 7, 14, 13)
            } else {
                c.beginPath(); c.arc(10, 10, 5, -0.8, 0.8); c.stroke()
                if (kind !== "volume-low") { c.beginPath(); c.arc(10, 10, 8, -0.8, 0.8); c.stroke() }
            }
        }
    }
}

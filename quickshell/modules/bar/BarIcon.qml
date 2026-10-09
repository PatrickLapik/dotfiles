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
        c.lineWidth = 1.5
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
        } else if (kind === "bell" || kind === "bell-off") {
            c.beginPath(); c.moveTo(4, 14); c.lineTo(5, 12); c.lineTo(5, 8);
            c.bezierCurveTo(5, 1, 15, 1, 15, 8); c.lineTo(15, 12); c.lineTo(16, 14); c.closePath(); c.stroke()
            c.beginPath(); c.arc(10, 15, 2, 0, Math.PI); c.stroke()
            if (kind === "bell-off") line(2, 2, 18, 18)
        } else if (kind === "wallpaper") {
            c.strokeRect(2, 3, 16, 14)
            c.beginPath(); c.moveTo(3, 15); c.lineTo(8, 9); c.lineTo(12, 13); c.lineTo(15, 10); c.lineTo(18, 14); c.stroke()
            c.beginPath(); c.arc(13, 7, 1.2, 0, Math.PI * 2); c.fill()
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

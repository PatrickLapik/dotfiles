import QtQuick
import qs.config
import qs.services

Item {
    id: root
    property alias text: label.text
    property alias font: label.font
    property alias color: label.color
    property real offset: 0
    readonly property real overflow: Math.max(0, label.implicitWidth - width)
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight
    clip: true
    function restart() { motion.stop(); offset = 0; if (overflow > 0 && visible && Animations.enabled) motion.start() }
    onTextChanged: Qt.callLater(restart)
    onWidthChanged: Qt.callLater(restart)
    onOverflowChanged: Qt.callLater(restart)
    onVisibleChanged: Qt.callLater(restart)
    Connections { target: Animations; function onEnabledChanged() { root.restart() } }
    Text {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        color: Colors.text
        font.weight: Theme.fontWeight; font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        transform: Translate { x: -root.offset }
    }
    SequentialAnimation {
        id: motion
        loops: Animation.Infinite
        PauseAnimation { duration: Animations.marqueePause }
        NumberAnimation { target: root; property: "offset"; to: root.overflow; duration: Math.max(1, root.overflow / Animations.marqueePixelsPerSecond * 1000) }
        PauseAnimation { duration: Animations.marqueePause }
        NumberAnimation { target: root; property: "offset"; to: 0; duration: Math.max(1, root.overflow / Animations.marqueePixelsPerSecond * 1000) }
    }
}

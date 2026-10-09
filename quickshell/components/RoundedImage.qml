import QtQuick
import QtQuick.Effects
import qs.components.containers
import qs.config
import qs.services

Item {
    id: root
    property alias source: picture.source
    property alias sourceSize: picture.sourceSize
    readonly property alias status: picture.status
    property real radius: Theme.radiusSmall
    Image {
        id: picture
        anchors.fill: parent
        asynchronous: true
        fillMode: Image.PreserveAspectCrop
        visible: false
        layer.enabled: true
    }
    StyledContainer {
        id: roundedMask
        anchors.fill: parent
        radius: root.radius
        color: Colors.text
        highlightOpacity: 0
        border.width: Theme.borderNone
        visible: false
        layer.enabled: true
    }
    MultiEffect {
        anchors.fill: parent
        source: picture
        maskEnabled: true
        maskSource: roundedMask
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
    }
}

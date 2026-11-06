import QtQuick
import QtQuick.Controls
import qs.components.containers
import qs.config
import qs.services

ToolTip {
    id: root
    padding: Spacing.sm
    x: (parent.width - width) / 2
    y: -height - Spacing.sm
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    background: StyledContainer {
        radius: Theme.radiusSmall
        color: Colors.surfaceContainerHigh
    }
    contentItem: Text {
        text: root.text
        textFormat: Text.PlainText
        font: root.font
        color: Colors.onSurface
    }
    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0; to: 1
            duration: Animations.enabled ? Animations.revealDuration : 0
            easing.type: Animations.revealEasing
        }
    }
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1; to: 0
            duration: Animations.enabled ? Animations.collapseDuration : 0
            easing.type: Animations.collapseEasing
        }
    }
}

import QtQuick
import QtQuick.Controls
import qs.components.containers
import qs.config
import qs.services

Button {
    id: root
    property bool middleClickEnabled: false
    property bool scrollActionEnabled: false
    signal middleClicked()
    signal scrolled(int direction)
    hoverEnabled: true
    padding: Spacing.sm
    font.weight: Theme.fontWeight; font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.letterSpacing: Theme.buttonLetterSpacing
    property MouseArea cursorArea: MouseArea {
        parent: root
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: root.middleClickEnabled ? Qt.MiddleButton : Qt.NoButton
        onClicked: root.middleClicked()
        onWheel: event => {
            if (!root.scrollActionEnabled || event.angleDelta.y === 0) { event.accepted = false; return }
            root.scrolled(event.angleDelta.y > 0 ? 1 : -1)
        }
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
    background: StyledContainer {
        radius: Theme.radiusSmall
        color: root.down || root.checked ? Colors.primaryContainer
            : root.hovered ? Colors.surfaceContainerHighest : Colors.surfaceContainerHigh
        border.width: root.visualFocus ? Theme.borderSelectedWidth : Theme.metalStyle ? Theme.borderWidth : Theme.borderNone
        border.color: root.visualFocus || root.hovered || root.checked ? Colors.primary : Colors.border
    }
    contentItem: Text {
        text: root.text
        textFormat: Text.PlainText
        font: root.font
        color: root.enabled ? Colors.text : Colors.textMuted
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}

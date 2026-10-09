import QtQuick
import qs.components
import qs.components.containers
import QtQuick.Layouts
import qs.services
import qs.config

StyledButton {
    id: root
    property string statusIcon: ""
    property string label: ""
    property string tooltip: ""
    property color tint: Colors.text
    property bool interactive: false
    enabled: interactive
    scrollActionEnabled: interactive
    implicitWidth: content.implicitWidth + Spacing.sm
    implicitHeight: Sizing.widgetHeight
    padding: 0
    background: StyledContainer {
        radius: Theme.radiusSmall
        color: root.hovered ? Colors.surfaceContainerHighest : "transparent"
        border.width: root.visualFocus ? Theme.borderSelectedWidth : 0
        border.color: Colors.primary
    }
    contentItem: RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: Spacing.xs
        BarIcon { visible: root.statusIcon !== ""; kind: root.statusIcon; tint: root.tint }
        Text {
            visible: root.label !== ""
            text: root.label
            color: root.tint
            font.weight: Theme.fontWeight; font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }
    BarToolTip {
        target: root
        hovered: root.cursorArea.containsMouse
        text: root.tooltip
    }
}

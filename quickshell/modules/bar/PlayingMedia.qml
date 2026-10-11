import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.components.containers
import qs.config
import qs.services

RowLayout {
    id: root
    spacing: Spacing.xs
    StyledContainer {
        id: track
        WidgetAnchor { name: "media"; target: track }
        Layout.preferredWidth: Math.min(title.implicitWidth + 10 + Sizing.barIconSize + Spacing.xs, Sizing.mediaTextMaxWidth)
        Layout.maximumWidth: Sizing.mediaTextMaxWidth
        implicitHeight: Sizing.widgetHeight
        radius: Theme.radiusSmall
        border.width: Theme.borderNone
        color: "transparent"
        RowLayout {
            anchors.fill: parent
            spacing: Spacing.sm
            BarIcon {
                kind: "music"
                Layout.preferredWidth: Sizing.barIconSize
                Layout.preferredHeight: Sizing.barIconSize
                tint: Media.available ? Colors.text : Colors.textMuted
            }
            ScrollingText {
                id: title
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.preferredWidth: 0
                text: Media.description
                color: Media.available ? Colors.text : Colors.textMuted
                font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Widgets.toggle("media", track.QsWindow.window.screen.name)
        }
    }
}

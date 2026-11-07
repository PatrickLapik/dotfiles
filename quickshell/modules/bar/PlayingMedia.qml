import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.components.containers
import qs.config
import qs.services

RowLayout {
    id: root
    spacing: Spacing.barStatusGap
    StyledContainer {
        id: track
        WidgetAnchor { name: "media"; target: track }
        Layout.preferredWidth: Math.min(title.implicitWidth + musicIcon.implicitWidth + Spacing.barContentGap + Spacing.barStatusPadding * 2, Sizing.mediaTextMaxWidth)
        Layout.maximumWidth: Sizing.mediaTextMaxWidth
        implicitHeight: Sizing.widgetHeight
        radius: Theme.radiusSmall
        border.width: Theme.borderNone
        color: "transparent"
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Spacing.barStatusPadding
            anchors.rightMargin: Spacing.barStatusPadding
            spacing: Spacing.barContentGap
            BarIcon {
                id: musicIcon
                kind: "music"
                Layout.preferredWidth: implicitWidth
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

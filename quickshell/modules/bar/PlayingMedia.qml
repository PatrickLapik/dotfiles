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
        Layout.preferredWidth: Math.min(title.implicitWidth + Spacing.sm * 2, Sizing.mediaTextMaxWidth)
        Layout.maximumWidth: Sizing.mediaTextMaxWidth
        implicitHeight: Sizing.widgetHeight
        radius: Theme.radiusSmall
        border.width: Theme.borderNone
        color: "transparent"
        ScrollingText {
            id: title
            anchors.fill: parent
            anchors.leftMargin: Spacing.sm
            anchors.rightMargin: Spacing.sm
            text: Media.description
            color: Media.available ? Colors.text : Colors.textMuted
            font.weight: Theme.fontWeight; font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
        MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Widgets.toggle("media", track.QsWindow.window.screen.name)
        }
        BarToolTip { target: track; hovered: hover.containsMouse; text: Media.description }
    }
    Repeater {
        model: ["previous", "toggle", "next"]
        delegate: StyledButton {
            id: control
            required property string modelData
            readonly property bool usable: Media.available && (modelData === "previous" ? Media.player.canGoPrevious : modelData === "next" ? Media.player.canGoNext : Media.player.canTogglePlaying)
            visible: Media.available
            enabled: usable
            implicitWidth: Sizing.widgetHeight
            implicitHeight: Sizing.widgetHeight
            padding: Spacing.xs
            text: modelData === "previous" ? "⏮" : modelData === "next" ? "⏭" : Media.playing ? "⏸" : "▶"
            Accessible.name: modelData === "previous" ? "Previous track" : modelData === "next" ? "Next track" : Media.playing ? "Pause" : "Play"
            background: StyledContainer {
                radius: Theme.radiusSmall
                border.width: Theme.borderNone
                color: control.hovered && control.usable ? Colors.surfaceContainerHighest : "transparent"
            }
            onClicked: {
                if (modelData === "previous") Media.previous()
                else if (modelData === "next") Media.next()
                else Media.toggle()
            }
            BarToolTip { target: control; hovered: control.hovered; text: control.Accessible.name }
        }
    }
}

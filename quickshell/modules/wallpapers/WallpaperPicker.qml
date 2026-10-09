import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services

Rectangle {
    id: root
    implicitWidth: 106
    implicitHeight: 28
    radius: Theme.radiusSmall
    color: trigger.containsMouse || picker.visible ? Colors.primaryContainer : "transparent"
    Text {
        anchors.centerIn: parent
        text: "Wallpapers"
        color: Colors.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
    }
    MouseArea {
        id: trigger
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            picker.visible = !picker.visible
            if (picker.visible) Wallpapers.refresh()
        }
    }
    PopupWindow {
        id: picker
        anchor.item: root
        anchor.edges: Edges.Bottom | Edges.Right
        anchor.gravity: Edges.Bottom | Edges.Left
        implicitWidth: 580
        implicitHeight: 480
        color: "transparent"
        grabFocus: true
        Rectangle {
            anchors.fill: parent
            color: Colors.surfaceContainer
            radius: Theme.radius
            border.color: Colors.border
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Spacing.lg
                spacing: Spacing.md
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Wallpapers"
                        color: Colors.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeLarge
                        Layout.fillWidth: true
                    }
                    Button {
                        text: "Refresh"
                        enabled: !Wallpapers.busy && !Wallpapers.scanning
                        onClicked: Wallpapers.refresh()
                    }
                    Button { text: "Close"; onClicked: picker.visible = false }
                }
                TextField {
                    id: search
                    Layout.fillWidth: true
                    placeholderText: "Search wallpapers…"
                    color: Colors.text
                    font.family: Theme.fontFamily
                    background: Rectangle { color: Colors.surfaceContainerHighest; radius: Theme.radiusSmall }
                    Keys.onEscapePressed: picker.visible = false
                }
                Text {
                    Layout.fillWidth: true
                    text: Wallpapers.error || (Wallpapers.busy ? "Generating colors and changing wallpaper…" : Wallpapers.scanning ? "Looking for wallpapers…" : "Choose a wallpaper · " + Wallpapers.items.length + " images")
                    color: Wallpapers.error ? Colors.error : Colors.textMuted
                    wrapMode: Text.Wrap
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
                GridView {
                    id: grid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    cellWidth: width / 3
                    cellHeight: 126
                    model: Wallpapers.items.filter(item => item.name.toLowerCase().includes(search.text.toLowerCase()))
                    ScrollBar.vertical: ScrollBar {}
                    delegate: Rectangle {
                        id: tile
                        required property var modelData
                        width: grid.cellWidth - Spacing.sm
                        height: grid.cellHeight - Spacing.sm
                        radius: Theme.radiusSmall
                        color: hover.containsMouse ? Colors.surfaceContainerHighest : Colors.surfaceContainerLow
                        border.width: modelData.path === Wallpapers.current ? 2 : 1
                        border.color: modelData.path === Wallpapers.current ? Colors.primary : Colors.border
                        Image {
                            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 4 }
                            height: 80
                            source: tile.modelData.url
                            sourceSize.width: 320
                            sourceSize.height: 180
                            asynchronous: true
                            fillMode: Image.PreserveAspectCrop
                            clip: true
                        }
                        Text {
                            anchors { bottom: parent.bottom; left: parent.left; right: parent.right; margins: Spacing.sm }
                            text: tile.modelData.name
                            elide: Text.ElideMiddle
                            color: Colors.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }
                        MouseArea {
                            id: hover
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: !Wallpapers.busy && !Wallpapers.scanning
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Wallpapers.select(tile.modelData.path)
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: grid.count === 0 && !Wallpapers.scanning
                        text: search.text ? "No matching wallpapers" : "No wallpapers found"
                        color: Colors.textMuted
                    }
                }
            }
        }
    }
}

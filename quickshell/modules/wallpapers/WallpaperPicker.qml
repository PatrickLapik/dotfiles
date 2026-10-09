import QtQuick
import qs.components
import qs.components.containers
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services

StyledContainer {
    id: root
    signal pickerOpened()
    function openPicker() { picker.open() }
    border.width: Theme.borderNone
    implicitWidth: Sizing.wallpaperButtonWidth
    implicitHeight: Sizing.widgetHeight
    radius: Theme.radiusSmall
    color: trigger.containsMouse || picker.visible ? Colors.primaryContainer : "transparent"
    Text {
        anchors.centerIn: parent
        text: "Wallpapers"
        color: Colors.text
        font.weight: Theme.fontWeight; font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
    }
    MouseArea {
        id: trigger
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            picker.toggle()
        }
    }
    CenteredPopup {
        id: picker
        popupWidth: Sizing.wallpaperPickerWidth
        popupHeight: Sizing.wallpaperPickerHeight
        padding: Spacing.xl
        screen: root.QsWindow.window ? root.QsWindow.window.screen : null
        onOpened: {
            root.pickerOpened()
            Wallpapers.refresh()
            Qt.callLater(() => search.forceActiveFocus())
        }
        ColumnLayout {
            anchors.fill: parent
            spacing: Spacing.lg
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Wallpapers"
                    color: Colors.text
                    Layout.maximumHeight: Theme.headingLineHeight
                font.weight: Theme.headingFontWeight; font.family: Theme.headingFontFamily
                    font.letterSpacing: Theme.headingLetterSpacing
                    font.pixelSize: Theme.fontSizeLarge
                    Layout.fillWidth: true
                }
                StyledButton {
                    font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    padding: Spacing.sm
                    text: "Refresh"
                    background: StyledContainer {
                        radius: Theme.radiusSmall
                        color: parent.hovered ? Colors.surfaceContainerHighest : Colors.surfaceContainerHigh
                    }
                    enabled: !Wallpapers.busy && !Wallpapers.scanning
                    onClicked: Wallpapers.refresh()
                }
                StyledButton {
                    font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    padding: Spacing.sm
                    text: "Close"
                    onClicked: picker.close()
                    background: StyledContainer {
                        radius: Theme.radiusSmall
                        color: parent.hovered ? Colors.surfaceContainerHighest : Colors.surfaceContainerHigh
                    }
                }
            }
            TextField {
                id: search
                Layout.fillWidth: true
                placeholderTextColor: Colors.textMuted
                selectionColor: Colors.primaryContainer
                selectedTextColor: Colors.onPrimaryContainer
                placeholderText: "Search wallpapers…"
                padding: Spacing.sm
                color: Colors.text
                font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                background: StyledContainer { color: Colors.surfaceContainerHighest; radius: Theme.radiusSmall }
                Keys.onEscapePressed: picker.close()
            }
            Text {
                Layout.fillWidth: true
                text: Wallpapers.error || (Wallpapers.busy ? "Generating colors and changing wallpaper…" : Wallpapers.scanning ? "Looking for wallpapers…" : "Choose a wallpaper · " + Wallpapers.items.length + " images")
                color: Wallpapers.error ? Colors.error : Colors.textMuted
                wrapMode: Text.Wrap
                font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }
            GridView {
                boundsBehavior: Flickable.StopAtBounds
                id: grid
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                cellWidth: width / Math.max(1, Math.min(Sizing.wallpaperColumns,
                    Math.floor(width / Sizing.wallpaperMinCellWidth)))
                cellHeight: Sizing.wallpaperCellHeight
                model: Wallpapers.items.filter(item => item.name.toLowerCase().includes(search.text.toLowerCase()))
                ScrollBar.vertical: StyledScrollBar {}
                delegate: StyledContainer {
                    id: tile
                    required property var modelData
                    width: grid.cellWidth - Spacing.md
                    height: grid.cellHeight - Spacing.md
                    radius: Theme.radiusSmall
                    color: hover.containsMouse ? Colors.surfaceContainerHighest : Colors.surfaceContainerLow
                    Image {
                        anchors { top: parent.top; left: parent.left; right: parent.right; margins: Spacing.xs }
                        height: Sizing.wallpaperPreviewHeight
                        source: tile.modelData.url
                        sourceSize.width: Sizing.wallpaperThumbnailWidth
                        sourceSize.height: Sizing.wallpaperThumbnailHeight
                        asynchronous: true
                        fillMode: Image.PreserveAspectCrop
                        clip: true
                    }
                    Text {
                        anchors { bottom: parent.bottom; left: parent.left; right: parent.right; margins: Spacing.sm }
                        text: tile.modelData.name
                        elide: Text.ElideMiddle
                        color: Colors.text
                        font.weight: Theme.fontWeight; font.family: Theme.fontFamily
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
                    font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Colors.textMuted
                }
            }
        }
    }
}

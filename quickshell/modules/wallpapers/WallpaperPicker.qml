pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.components.containers
import qs.config
import qs.services

Scope {
    WidgetEndpoint {
        name: "wallpapers"
        openAction: screenName => { picker.screen = Widgets.screenFor(screenName); picker.open() }
        closeAction: () => picker.close()
    }
    CenteredPopup {
        id: picker
        popupWidth: Sizing.wallpaperPickerWidth
        popupHeight: Sizing.wallpaperPickerHeight
        padding: Spacing.lg
        onOpened: {
            Wallpapers.refresh()
            Qt.callLater(() => search.forceActiveFocus())
        }
        onDismissed: Widgets.closed("wallpapers")
        ColumnLayout {
            anchors.fill: parent
            spacing: Spacing.md
            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: "Wallpapers"
                    color: Colors.text
                    font.family: Theme.headingFontFamily
                    font.weight: Theme.headingFontWeight
                    font.pixelSize: Theme.fontSizeLarge
                }
                StyledIconButton {
                    iconName: "restart"
                    Accessible.name: "Refresh wallpapers"
                    enabled: !Wallpapers.busy && !Wallpapers.scanning
                    onClicked: Wallpapers.refresh()
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
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                background: StyledContainer {
                    color: Colors.surfaceContainerHigh
                    radius: Theme.radiusSmall
                    border.width: search.activeFocus ? Theme.borderWidth : Theme.borderNone
                    border.color: Colors.primary
                }
                Keys.onEscapePressed: picker.close()
            }
            Text {
                Layout.fillWidth: true
                text: Wallpapers.error || (Wallpapers.busy ? "Changing wallpaper…" : Wallpapers.scanning ? "Looking for wallpapers…" : Wallpapers.items.length + " wallpapers")
                color: Wallpapers.error ? Colors.error : Colors.textMuted
                wrapMode: Text.Wrap
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }
            GridView {
                id: grid
                boundsBehavior: Flickable.StopAtBounds
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                cellWidth: width / Math.max(1, Math.min(Sizing.wallpaperColumns,
                    Math.floor(width / Sizing.wallpaperMinCellWidth)))
                cellHeight: Sizing.wallpaperCellHeight
                model: Wallpapers.items.filter(item => item.name.toLowerCase().includes(search.text.toLowerCase()))
                ScrollBar.vertical: StyledScrollBar {}
                delegate: StyledButton {
                    id: tile
                    required property var modelData
                    readonly property bool current: modelData.path === Wallpapers.current
                    width: grid.cellWidth - Spacing.md
                    height: grid.cellHeight - Spacing.md
                    padding: Spacing.xs
                    enabled: !Wallpapers.busy && !Wallpapers.scanning
                    Accessible.name: modelData.name + (current ? ", current wallpaper" : "")
                    onClicked: Wallpapers.select(modelData.path)
                    background: StyledContainer {
                        radius: Theme.radius
                        color: tile.current ? Colors.primaryContainer
                            : tile.hovered ? Colors.surfaceContainerHigh : "transparent"
                        border.width: tile.visualFocus ? Theme.borderSelectedWidth : Theme.borderNone
                        border.color: Colors.primary
                    }
                    contentItem: ColumnLayout {
                        spacing: Spacing.sm
                        RoundedImage {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Sizing.wallpaperPreviewHeight
                            source: tile.modelData.url
                            sourceSize.width: Sizing.wallpaperThumbnailWidth
                            sourceSize.height: Sizing.wallpaperThumbnailHeight
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: Spacing.xs
                            Layout.rightMargin: Spacing.xs
                            spacing: Spacing.xs
                            Text {
                                Layout.fillWidth: true
                                text: tile.modelData.name
                                elide: Text.ElideMiddle
                                color: tile.current ? Colors.onPrimaryContainer : Colors.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                            }
                            ShellIcon {
                                visible: tile.current
                                kind: "check"
                                tint: Colors.onPrimaryContainer
                            }
                        }
                    }
                }
                Text {
                    anchors.centerIn: parent
                    visible: grid.count === 0 && !Wallpapers.scanning
                    text: search.text ? "No matching wallpapers" : "No wallpapers found"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Colors.textMuted
                }
            }
        }
    }
}

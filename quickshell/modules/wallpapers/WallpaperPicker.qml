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
        popupName: "wallpapers"
        popupWidth: Sizing.wallpaperPickerWidth
        popupHeight: Sizing.wallpaperPickerHeight
        padding: Spacing.lg
        onOpened: {
            Wallpapers.refresh()
            Qt.callLater(() => toolbar.focusSearch())
        }
        onDismissed: {
            schemeDropdown.popup.close()
            Widgets.closed("wallpapers")
        }
        ColumnLayout {
            anchors.fill: parent
            spacing: Spacing.md
            PopupToolbar {
                id: toolbar
                Layout.fillWidth: true
                title: "Wallpapers"
                placeholderText: "Search wallpapers…"
                countText: searchText ? grid.count + " of " + Wallpapers.items.length
                    : Wallpapers.items.length + " wallpapers"
                onSearchTextChanged: grid.positionViewAtBeginning()
                onSearchKeyPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        picker.close()
                        event.accepted = true
                    }
                }
                StyledIconButton {
                    iconName: "restart"
                    Accessible.name: "Refresh wallpapers"
                    enabled: !Wallpapers.busy && !Wallpapers.scanning
                    onClicked: Wallpapers.refresh()
                }
            }
            GridView {
                id: grid
                boundsBehavior: Flickable.StopAtBounds
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 0
                // Reserve a scrollbar gutter; each cell has equal side insets.
                readonly property real galleryWidth: Math.max(0, width - Sizing.scrollBarWidth - Spacing.xs)
                readonly property int columns: Math.max(1, Math.min(Sizing.wallpaperColumns,
                    Math.floor(galleryWidth / Sizing.wallpaperMinCellWidth)))
                readonly property real previewHeight: Math.max(0,
                    cellWidth - Spacing.md - Spacing.xs * 2) / Sizing.wallpaperPreviewAspectRatio
                implicitWidth: Sizing.wallpaperColumns * Sizing.wallpaperMinCellWidth
                clip: true
                cellWidth: galleryWidth / columns
                cellHeight: previewHeight + Spacing.sm + Sizing.wallpaperCaptionHeight + Spacing.xs * 2 + Spacing.md
                model: Wallpapers.items.filter(item => item.name.toLowerCase().includes(toolbar.searchText.toLowerCase()))
                ScrollBar.vertical: StyledScrollBar {}
                delegate: Item {
                    id: cell
                    required property var modelData
                    width: grid.cellWidth
                    height: grid.cellHeight
                    StyledButton {
                        id: tile
                        readonly property var modelData: cell.modelData
                        readonly property bool current: modelData.path === Wallpapers.current
                        x: Spacing.md / 2
                        width: Math.max(0, grid.cellWidth - Spacing.md)
                        height: grid.cellHeight - Spacing.md
                        padding: Spacing.xs
                        highlightInteractions: false
                        enabled: !Wallpapers.busy && !Wallpapers.scanning
                        Accessible.name: modelData.name + (current ? ", current wallpaper" : "")
                        onClicked: Wallpapers.select(modelData.path)
                        background: StyledContainer {
                            radius: Theme.radiusSmall
                            color: tile.hovered ? Colors.surfaceContainerHigh : "transparent"
                            border.width: tile.current || tile.visualFocus ? Theme.borderSelectedWidth : Theme.borderNone
                            border.color: Colors.primary
                        }
                        contentItem: Item {
                            RoundedImage {
                                id: preview
                                width: parent.width
                                height: grid.previewHeight
                                source: tile.modelData.url
                                sourceSize.width: Sizing.wallpaperThumbnailWidth
                                sourceSize.height: Sizing.wallpaperThumbnailHeight
                                StyledContainer {
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.margins: Spacing.sm
                                    width: Sizing.barIconSize + Spacing.xs * 2
                                    height: width
                                    visible: tile.current
                                    radius: Theme.radiusSmall
                                    color: Colors.primaryContainer
                                    ShellIcon {
                                        anchors.centerIn: parent
                                        kind: "check"
                                        tint: Colors.onPrimaryContainer
                                    }
                                }
                            }
                            Text {
                                anchors.top: preview.bottom
                                anchors.topMargin: Spacing.sm
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: Spacing.xs
                                anchors.rightMargin: Spacing.xs
                                height: Sizing.wallpaperCaptionHeight
                                text: tile.modelData.name.replace(/\.[^.]+$/, "")
                                textFormat: Text.PlainText
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                                color: tile.current ? Colors.text : Colors.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }
                    }
                }
                Text {
                    anchors.centerIn: parent
                    visible: grid.count === 0
                    text: Wallpapers.scanning ? "Looking for wallpapers…"
                        : toolbar.searchText ? "No matching wallpapers" : "No wallpapers found"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Colors.textMuted
                }
            }
            Rectangle {
                Layout.fillWidth: true
                height: Theme.borderWidth
                color: Colors.border
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: Spacing.sm
                Text {
                    text: "Color scheme"
                    color: Colors.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
                StyledDropdown {
                    id: schemeDropdown
                    Layout.preferredWidth: Math.min(Sizing.wallpaperSchemeWidth, picker.surface.width * 0.4)
                    model: Wallpapers.schemeTypes.map(scheme => ({ label: scheme.replace(/^scheme-/, "")
                        .split("-").map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(" ") }))
                    textRole: "label"
                    currentIndex: Wallpapers.schemeIndex
                    enabled: !Wallpapers.busy && !Wallpapers.scanning
                    Accessible.name: "Wallpaper color scheme"
                    onActivated: index => Wallpapers.setScheme(index)
                }
                Text {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    text: Wallpapers.error || (Wallpapers.busy ? "Applying wallpaper…" : Wallpapers.scanning ? "Refreshing…" : "")
                    color: Wallpapers.error ? Colors.error : Colors.textMuted
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }
    }
}

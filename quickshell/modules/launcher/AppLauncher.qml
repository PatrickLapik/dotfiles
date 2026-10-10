pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.components
import qs.components.containers
import qs.config
import qs.services
import "Fuzzy.js" as Fuzzy

Scope {
    id: root
    FontMetrics { id: appFont; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
    FontMetrics { id: descriptionFont; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
    function show(screenName: string) {
        popup.screen = Widgets.screenFor(screenName)
        if (popup.isOpen) {
            search.clear()
            search.forceActiveFocus()
        } else popup.open()
    }
    IpcHandler {
        target: "launcher"
        function open(screenName: string): void { Widgets.open("launcher", screenName) }
    }
    WidgetEndpoint {
        name: "launcher"
        openAction: screenName => root.show(screenName)
        closeAction: () => popup.close()
    }
    CenteredPopup {
        id: popup
        popupName: "launcher"
        popupWidth: Sizing.launcherWidth
        popupHeight: Sizing.launcherHeight
        keepBarVisible: false
        onDismissed: Widgets.closed("launcher")
        onOpened: {
            search.clear()
            Qt.callLater(() => search.forceActiveFocus())
        }
        readonly property var results: Fuzzy.rank(search.text, DesktopEntries.applications.values)
        onResultsChanged: list.currentIndex = results.length ? 0 : -1

        function moveSelection(delta: int) {
            if (!results.length) return
            list.currentIndex = (Math.max(0, list.currentIndex) + delta + results.length) % results.length
            list.positionViewAtIndex(list.currentIndex, ListView.Contain)
        }
        function launch(index: int) {
            const entry = results[index]
            if (!entry) return
            // GTK handles desktop Exec field codes, working directories, and Terminal entries.
            Quickshell.execDetached(["gtk-launch", entry.id])
            close()
        }
        ColumnLayout {
            anchors.fill: parent
            spacing: Spacing.md
            Text {
                text: "Applications"
                color: Colors.text
                Layout.maximumHeight: Theme.headingLineHeight
                font.weight: Theme.headingFontWeight; font.family: Theme.headingFontFamily
                font.letterSpacing: Theme.headingLetterSpacing
                font.pixelSize: Theme.fontSizeLarge
            }
            TextField {
                id: search
                Layout.fillWidth: true
                placeholderTextColor: Colors.textMuted
                selectionColor: Colors.primaryContainer
                selectedTextColor: Colors.onPrimaryContainer
                placeholderText: "Search applications…"
                padding: Spacing.md
                color: Colors.text
                font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                background: StyledContainer {
                    radius: Theme.radiusSmall
                    color: Colors.surfaceContainerHigh
                    border.width: search.activeFocus ? Theme.borderWidth : Theme.borderNone
                    border.color: Colors.primary
                }
                Keys.priority: Keys.BeforeItem
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier)) popup.moveSelection(1)
                    else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab || event.key === Qt.Key_Tab && event.modifiers & Qt.ShiftModifier) popup.moveSelection(-1)
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) popup.launch(list.currentIndex)
                    else if (event.key === Qt.Key_Escape) popup.close()
                    else return
                    event.accepted = true
                }
            }
            ListView {
                boundsBehavior: Flickable.StopAtBounds
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 0
                implicitWidth: count ? Math.max(Sizing.dropdownMinWidth, ...popup.results.map(entry =>
                    Math.max(appFont.advanceWidth(entry.name), descriptionFont.advanceWidth(entry.genericName || entry.comment || ""))
                    + Sizing.launcherIconSize + Spacing.sm * 2 + Spacing.md)) : emptyState.implicitWidth
                implicitHeight: Math.max(1, count) * Sizing.launcherRowHeight + Math.max(0, count - 1) * spacing
                clip: true
                spacing: Spacing.xs
                model: popup.results
                currentIndex: count ? 0 : -1
                ScrollBar.vertical: StyledScrollBar {}
                delegate: StyledContainer {
                    id: row
                    required property var modelData
                    required property int index
                    width: list.width
                    height: Sizing.launcherRowHeight
                    radius: Theme.radiusSmall
                    color: ListView.isCurrentItem ? Colors.primaryContainer : mouse.containsMouse ? Colors.surfaceContainerHigh : "transparent"
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Spacing.sm
                        spacing: Spacing.md
                        Item {
                            id: applicationIcon
                            Layout.preferredWidth: Sizing.launcherIconSize
                            Layout.preferredHeight: Sizing.launcherIconSize
                            readonly property string themeIcon: row.modelData.icon && Quickshell.hasThemeIcon(row.modelData.icon)
                                ? row.modelData.icon : ""
                            Image {
                                id: appIcon
                                anchors.fill: parent
                                source: applicationIcon.themeIcon ? Quickshell.iconPath(applicationIcon.themeIcon) : ""
                                sourceSize.width: Sizing.launcherIconSize
                                sourceSize.height: Sizing.launcherIconSize
                                fillMode: Image.PreserveAspectFit
                                visible: status === Image.Ready
                            }
                            ShellIcon {
                                anchors.fill: parent
                                visible: appIcon.status !== Image.Ready
                                kind: "application"
                                tint: row.ListView.isCurrentItem ? Colors.onPrimaryContainer : Colors.textMuted
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Spacing.xs
                            Text {
                                Layout.fillWidth: true
                                text: row.modelData.name
                                color: row.ListView.isCurrentItem ? Colors.onPrimaryContainer : Colors.text
                                font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: row.modelData.genericName || row.modelData.comment || ""
                                color: Colors.textMuted
                                font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                elide: Text.ElideRight
                            }
                        }
                    }
                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { list.currentIndex = row.index; popup.launch(row.index) }
                    }
                }
                Text {
                    id: emptyState
                    anchors.centerIn: parent
                    visible: list.count === 0
                    text: "No matching applications"
                    color: Colors.textMuted
                    font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }
            }
        }
    }
}

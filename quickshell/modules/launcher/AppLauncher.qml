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
                        Image {
                            Layout.preferredWidth: Sizing.launcherIconSize
                            Layout.preferredHeight: Sizing.launcherIconSize
                            source: Quickshell.iconPath(row.modelData.icon || "application-x-executable", "application-x-executable")
                            sourceSize.width: Sizing.launcherIconSize
                            sourceSize.height: Sizing.launcherIconSize
                            fillMode: Image.PreserveAspectFit
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
                                color: row.ListView.isCurrentItem ? Colors.onPrimaryContainer : Colors.textMuted
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
                    anchors.centerIn: parent
                    visible: list.count === 0
                    text: "No matching applications"
                    color: Colors.textMuted
                    font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }
            }
            Text {
                text: "↑ ↓ / Tab  Select     Enter  Launch     Esc  Close"
                color: Colors.textMuted
                font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }
}

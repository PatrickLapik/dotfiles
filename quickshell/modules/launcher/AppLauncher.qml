pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.components.containers
import qs.config
import qs.services
import "Fuzzy.js" as Fuzzy
import "Calculator.js" as Calculator

Scope {
    id: root
    // Keep the service alive to observe app usage even while the launcher is closed.
    readonly property var applications: Applications
    function show(screenName: string) {
        popup.screen = Widgets.screenFor(screenName)
        popup.reset()
        if (!popup.isOpen) popup.open()
        else toolbar.focusSearch()
    }
    WidgetEndpoint {
        name: "launcher"
        openAction: screenName => root.show(screenName)
        closeAction: () => popup.close()
    }
    CenteredPopup {
        id: popup
        objectName: "launcherPopup"
        popupName: "launcher"
        popupWidth: Sizing.launcherWidth
        popupHeight: Sizing.launcherHeight
        keepBarVisible: false
        property bool settings: false
        property bool confirmClear: false
        property string notice: ""
        readonly property bool searching: toolbar.searchText.trim().length > 0
        readonly property var selected: results[list.currentIndex] || null
        readonly property var results: buildResults()
        onResultsChanged: list.currentIndex = results.length ? 0 : -1
        onDismissed: Widgets.closed("launcher")
        onOpened: Qt.callLater(() => toolbar.focusSearch())

        function reset() { settings = false; confirmClear = false; notice = ""; toolbar.clearSearch() }
        function appRow(entry: var): var {
            const count = Applications.windowsFor(entry.id).length
            return {kind: "app", entry: entry, id: entry.id, name: entry.name, genericName: entry.genericName,
                keywords: entry.keywords, icon: entry.icon,
                detail: count ? "Launch new · " + count + (count === 1 ? " open window" : " open windows") : "Launch application"}
        }
        function buildResults(): var {
            const query = toolbar.searchText.trim()
            const windowRows = Applications.windows.map(row => Object.assign({}, row, {detail: "Switch to window · " + row.genericName}))
            const apps = Applications.entries.map(entry => appRow(entry))
            const rows = Fuzzy.grouped(query, apps, windowRows, id => Applications.boost(id))
            const result = Calculator.calculate(query)
            if (result !== null) rows.unshift({kind: "calculator", id: "calculator", name: result, detail: query + " · Enter to copy", icon: "accessories-calculator"})
            return rows
        }
        function moveSelection(delta: int) {
            if (!results.length) return
            list.currentIndex = (Math.max(0, list.currentIndex) + delta + results.length) % results.length
            list.positionViewAtIndex(list.currentIndex, ListView.Contain)
        }
        function navigate(event: var): bool {
            const control = !!(event.modifiers & Qt.ControlModifier)
            if (event.key === Qt.Key_Down || control && event.key === Qt.Key_N) moveSelection(1)
            else if (event.key === Qt.Key_Up || control && event.key === Qt.Key_P) moveSelection(-1)
            else return false
            toolbar.focusSearch()
            event.accepted = true
            return true
        }
        function activate(row: var) {
            if (!row) return
            if (row.kind === "calculator") {
                Quickshell.clipboardText = row.name
                notice = "Copied " + row.name
            } else if (row.kind === "window") {
                if (!Applications.windowAddress(row.window)) {
                    notice = "This window is no longer available"
                    return
                }
                // Release the launcher's exclusive keyboard focus before dispatching.
                const window = row.window
                close()
                Qt.callLater(() => Applications.focusWindow(window))
            } else { Applications.launch(row.entry); close() }
        }
        ColumnLayout {
            anchors.fill: parent
            spacing: Spacing.md
            Keys.onPressed: event => popup.navigate(event)
            Keys.onEscapePressed: event => { popup.close(); event.accepted = true }
            PopupToolbar {
                id: toolbar
                Layout.fillWidth: true
                title: "Launch & switch"
                placeholderText: "Search apps, windows, or calculate…"
                countText: popup.results.length + " results"
                Component.onCompleted: searchField.objectName = "launcherSearch"
                onSearchTextChanged: popup.notice = ""
                onSearchKeyPressed: event => {
                    if (popup.navigate(event)) return
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) popup.activate(popup.selected)
                    else if (event.key === Qt.Key_Escape) popup.close()
                    else return
                    event.accepted = true
                }
                StyledButton {
                    text: "History"
                    flat: true
                    onClicked: popup.settings = !popup.settings
                }
            }
            RowLayout {
                visible: popup.settings
                StyledButton { text: Applications.tracking ? "Tracking on" : "Tracking off"; enabled: Applications.ready; onClicked: Applications.toggleTracking() }
                StyledButton {
                    text: popup.confirmClear ? "Confirm clear" : "Clear history"
                    enabled: Applications.ready
                    onClicked: {
                        if (popup.confirmClear) { Applications.clearHistory(); popup.confirmClear = false; popup.notice = "History cleared" }
                        else popup.confirmClear = true
                    }
                }
            }
            ListView {
                id: list
                objectName: "launcherResults"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 0
                clip: true
                spacing: Spacing.xs
                boundsBehavior: Flickable.StopAtBounds
                model: popup.results
                currentIndex: count ? 0 : -1
                ScrollBar.vertical: StyledScrollBar {}
                delegate: Item {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool childWindow: !!modelData.child
                    readonly property bool nextIsChild: index + 1 < popup.results.length && !!popup.results[index + 1].child
                    readonly property real branchX: Spacing.sm + Sizing.launcherIconSize / 2
                    width: list.width
                    height: Sizing.launcherRowHeight

                    // Draw the trunk across delegate gaps; end at the last child's elbow.
                    Rectangle {
                        visible: row.childWindow || row.nextIsChild
                        x: row.branchX
                        y: row.childWindow ? -list.spacing : row.height / 2 + Sizing.launcherIconSize / 2 + Spacing.xs
                        width: Theme.borderWidth
                        height: Math.max(0, (row.nextIsChild ? row.height : row.height / 2) - y)
                        color: Colors.outline
                    }
                    Rectangle {
                        visible: row.childWindow
                        x: row.branchX
                        y: (row.height - height) / 2
                        width: Math.max(0, Spacing.launcherWindowIndent - x - Spacing.xs)
                        height: Theme.borderWidth
                        color: Colors.outline
                    }
                    StyledButton {
                        id: rowButton
                        x: row.childWindow ? Spacing.launcherWindowIndent : 0
                        width: Math.max(0, row.width - x)
                        height: row.height
                        Accessible.name: row.modelData.name + ", " + row.modelData.detail
                        onActiveFocusChanged: if (activeFocus) { list.currentIndex = row.index; list.positionViewAtIndex(row.index, ListView.Contain) }
                        Keys.priority: Keys.BeforeItem
                        Keys.onPressed: event => popup.navigate(event)
                        onClicked: { list.currentIndex = row.index; popup.activate(row.modelData) }
                        background: StyledContainer {
                            radius: Theme.radiusSmall
                            color: row.ListView.isCurrentItem || rowButton.visualFocus ? Colors.primaryContainer : rowButton.hovered ? Colors.surfaceContainerHigh : "transparent"
                        }
                        contentItem: RowLayout {
                            spacing: Spacing.md
                            LauncherIcon { icon: row.modelData.icon || ""; tint: row.ListView.isCurrentItem ? Colors.onPrimaryContainer : Colors.text }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Spacing.xs
                                Text { text: row.modelData.name; textFormat: Text.PlainText; color: row.ListView.isCurrentItem ? Colors.onPrimaryContainer : Colors.text; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; Layout.fillWidth: true; elide: Text.ElideRight }
                                Text { text: row.modelData.detail; textFormat: Text.PlainText; color: row.ListView.isCurrentItem ? Colors.onPrimaryContainer : Colors.textMuted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; Layout.fillWidth: true; elide: Text.ElideRight }
                            }
                        }
                    }
                }
                Text {
                    anchors.centerIn: parent
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    visible: list.count === 0
                    text: popup.searching ? (toolbar.searchText.trim().startsWith("=") ? "Enter a valid expression, such as = (12 + 8) / 5" : "No matching apps or windows")
                        : "No applications or windows available"
                    color: Colors.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }
            }
            Text {
                text: "↑↓ / Ctrl+N / Ctrl+P Select · Enter Launch or switch"
                color: Colors.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: Applications.error || popup.notice
                textFormat: Text.PlainText
                color: Applications.error ? Colors.error : Colors.tertiary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                wrapMode: Text.WordWrap
            }
        }
    }
}

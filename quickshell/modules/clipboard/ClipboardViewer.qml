pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.components.containers
import qs.config
import qs.services
import "ClipboardModel.js" as ClipboardModel

Scope {
    WidgetEndpoint {
        name: "clipboard"
        openAction: screenName => { popup.openFresh(screenName) }
        closeAction: () => popup.dismiss()
    }
    StyledPopup {
        id: popup
        popupName: "clipboard"
        popupWidth: Sizing.clipboardWidth
        popupHeight: Sizing.clipboardHeight
        alignment: Qt.AlignTop | Qt.AlignRight
        topMargin: ScreenLayout.barPopupTop
        rightMargin: Spacing.barRightMargin
        padding: Spacing.lg
        property bool opening: false
        property int openingTicket: 0
        property bool resettingSearch: false
        property bool confirmClear: false
        property string selectedEntryId: ""
        property int selectedEntryIndex: 0
        readonly property var results: Clipboard.entries.filter(entry => toolbar.searchText.trim().toLocaleLowerCase().split(/\s+/).every(word => entry.preview.toLocaleLowerCase().includes(word)))
        ListModel { id: entryModel }
        onResultsChanged: syncRows()
        function openFresh(screenName: string) {
            if (isOpen || opening) return
            screen = Widgets.screenFor(screenName)
            opening = true
            confirmClear = false
            resettingSearch = true
            toolbar.clearSearch()
            resettingSearch = false
            selectedEntryId = ""
            selectedEntryIndex = -1
            openingTicket = Clipboard.refresh()
        }
        function dismiss() {
            opening = false
            close()
            Widgets.closed("clipboard")
        }
        onOpened: Qt.callLater(() => toolbar.focusSearch())
        onDismissed: { opening = false; Widgets.closed("clipboard") }
        function selectEntry(index, scroll = true) {
            const next = entryModel.count ? Math.max(0, Math.min(index, entryModel.count - 1)) : -1
            selectedEntryIndex = next
            selectedEntryId = next >= 0 ? entryModel.get(next).entryId : ""
            list.currentIndex = next
            if (scroll && next >= 0) list.positionViewAtIndex(next, ListView.Contain)
        }
        function syncRows() {
            const stride = Sizing.clipboardRowHeight + list.spacing
            const offset = Math.max(0, list.contentY - list.originY)
            const topIndex = Math.min(entryModel.count - 1, Math.floor(offset / stride))
            const anchor = topIndex >= 0 ? entryModel.get(topIndex).entryId : ""
            const inset = offset - Math.max(0, topIndex) * stride
            ClipboardModel.syncEntries(entryModel, results)
            const selected = ClipboardModel.indexOf(entryModel, selectedEntryId)
            selectEntry(selected >= 0 ? selected : selectedEntryIndex, false)
            if (isOpen && !opening && anchor) {
                list.forceLayout()
                const anchorIndex = ClipboardModel.indexOf(entryModel, anchor)
                if (anchorIndex >= 0) {
                    list.positionViewAtIndex(anchorIndex, ListView.Beginning)
                    list.contentY = Math.max(list.originY, Math.min(list.contentY + inset,
                        list.originY + Math.max(0, list.contentHeight - list.height)))
                }
            }
        }
        function moveSelection(delta: int) {
            if (!entryModel.count) return
            selectEntry((Math.max(0, list.currentIndex) + delta + entryModel.count) % entryModel.count)
        }
        function copySelected() {
            const entry = results[list.currentIndex]
            if (entry) Clipboard.copy(entry.id)
        }
        function deleteSelected() {
            const entry = results[list.currentIndex]
            if (entry) removeEntry(entry.id)
        }
        function removeEntry(id: string) {
            if (Clipboard.busy) return
            const index = results.findIndex(entry => entry.id === id)
            if (index < 0) return
            if (selectedEntryId === id) selectEntry(index > 0 ? index - 1 : index + 1)
            Clipboard.remove(id)
        }
        Connections {
            target: Clipboard
            function onCopied() { if (popup.isOpen) popup.close() }
            function onRefreshed(ticket, success) {
                if (!popup.opening || ticket < popup.openingTicket) return
                popup.opening = false
                // Show cached results with the error footer if refreshing failed.
                popup.syncRows()
                popup.selectEntry(0)
                list.positionViewAtBeginning()
                popup.open()
            }
        }
        Timer { interval: Theme.clipboardPollInterval; running: popup.isOpen; repeat: true; onTriggered: Clipboard.refresh() }
        ColumnLayout {
            anchors.fill: parent
            spacing: Spacing.md
            PopupToolbar {
                id: toolbar
                Layout.fillWidth: true
                title: "Clipboard"
                placeholderText: "Search clipboard…"
                countText: searchText.trim() ? popup.results.length + " of " + Clipboard.entries.length
                    : Clipboard.entries.length + " items"
                onSearchTextChanged: {
                    if (!popup.resettingSearch) { popup.syncRows(); popup.selectEntry(0); list.positionViewAtBeginning() }
                    popup.confirmClear = false
                }
                onSearchKeyPressed: event => {
                    const control = !!(event.modifiers & Qt.ControlModifier)
                    if (event.key === Qt.Key_Down || control && event.key === Qt.Key_N) popup.moveSelection(1)
                    else if (event.key === Qt.Key_Up || control && event.key === Qt.Key_P) popup.moveSelection(-1)
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) popup.copySelected()
                    else if (event.key === Qt.Key_Delete && control) popup.deleteSelected()
                    else if (event.key === Qt.Key_Escape) popup.close()
                    else return
                    event.accepted = true
                }
            }
            StyledContainer {
                Layout.fillWidth: true
                implicitHeight: confirmation.implicitHeight + Spacing.sm * 2
                visible: popup.confirmClear
                color: Colors.surfaceContainerHigh
                RowLayout {
                    id: confirmation
                    anchors.fill: parent
                    anchors.margins: Spacing.sm
                    spacing: Spacing.sm
                    Text {
                        Layout.fillWidth: true
                        text: "Clear all history?"
                        wrapMode: Text.Wrap
                        color: Colors.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                    StyledButton { text: "Cancel"; onClicked: popup.confirmClear = false }
                    StyledButton {
                        text: "Clear"
                        enabled: !Clipboard.busy
                        onClicked: { Clipboard.clear(); popup.confirmClear = false }
                    }
                }
            }
            ListView {
                boundsBehavior: Flickable.StopAtBounds
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 0
                clip: true
                spacing: Spacing.xs
                model: entryModel
                currentIndex: -1
                ScrollBar.vertical: StyledScrollBar {}
                delegate: StyledContainer {
                    id: row
                    required property string entryId
                    required property string rawPreview
                    required property bool binaryEntry
                    readonly property var modelData: ({ id: entryId, preview: rawPreview, binary: binaryEntry })
                    required property int index
                    readonly property bool selected: ListView.isCurrentItem
                    readonly property string preview: String(modelData.preview).replace(/\s+/g, " ").trim()
                    readonly property var imageInfo: modelData.binary ? preview.match(/binary data (.+?) (png|jpg|jpeg|webp|gif|bmp) (\d+)x(\d+)/i) : null
                    readonly property string displayPreview: imageInfo
                        ? imageInfo[2].toUpperCase() + " image · " + imageInfo[3] + " × " + imageInfo[4] + " · " + imageInfo[1]
                        : modelData.binary ? preview.replace(/^\[\[\s*binary data\s*/, "File · ").replace(/\s*\]\]$/, "") : preview
                    width: list.width - Sizing.scrollBarWidth - Spacing.xs
                    height: Sizing.clipboardRowHeight
                    radius: Theme.radiusSmall
                    color: selected || rowHover.hovered ? Colors.surfaceContainerHigh : "transparent"
                    border.width: selected || copyButton.visualFocus || removeButton.visualFocus ? Theme.borderSelectedWidth : Theme.borderNone
                    border.color: Colors.primary
                    HoverHandler { id: rowHover }
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Spacing.sm
                        anchors.rightMargin: Spacing.sm
                        spacing: Spacing.sm
                        StyledButton {
                            id: copyButton
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            padding: Spacing.xs
                            Accessible.name: "Copy " + (row.modelData.binary ? "file from clipboard" : row.preview)
                            onClicked: { popup.selectEntry(row.index); Clipboard.copy(row.modelData.id) }
                            enabled: !Clipboard.busy
                            background: StyledContainer { color: "transparent"; border.width: Theme.borderNone }
                            contentItem: Text {
                                text: row.displayPreview
                                textFormat: Text.PlainText
                                wrapMode: Text.NoWrap
                                maximumLineCount: 1
                                elide: Text.ElideRight
                                color: Colors.text
                                font.weight: Theme.fontWeight
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        StyledIconButton {
                            id: removeButton
                            iconName: "trash"
                            // Reserve the slot so revealing the action never shifts text.
                            opacity: rowHover.hovered || visualFocus ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: Animations.enabled ? Animations.feedbackDuration : 0
                                    easing.type: Animations.feedbackEasing
                                }
                            }
                            tint: hovered ? Colors.onErrorContainer : row.selected ? Colors.text : Colors.textMuted
                            Layout.preferredWidth: Sizing.widgetHeight
                            Layout.preferredHeight: Sizing.widgetHeight
                            enabled: !Clipboard.busy
                            Accessible.name: "Remove clipboard entry"
                            onClicked: popup.removeEntry(row.modelData.id)
                            background: StyledContainer {
                                color: removeButton.hovered ? Colors.errorContainer : "transparent"
                                radius: Theme.radiusSmall
                                border.width: removeButton.visualFocus ? Theme.borderWidth : Theme.borderNone
                                border.color: Colors.primary
                            }
                        }
                    }
                }
                Text { id: emptyState; anchors.centerIn: parent; width: parent.width; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.Wrap; visible: list.count === 0; text: Clipboard.error ? "Could not load clipboard history" : toolbar.searchText ? "No matching entries" : "Your clipboard history is empty"; color: Colors.textMuted; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
            }
            Rectangle {
                Layout.fillWidth: true
                height: Theme.borderWidth
                color: Colors.border
            }
            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: Sizing.widgetHeight
                text: Clipboard.error || "Ctrl+N/P · Navigate    Enter · Copy    Ctrl+Delete · Remove"
                textFormat: Text.PlainText
                color: Clipboard.error ? Colors.error : Colors.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }
    }
}

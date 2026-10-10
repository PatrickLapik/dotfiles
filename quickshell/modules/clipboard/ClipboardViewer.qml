pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.components.containers
import qs.config
import qs.services
import qs.modules.bar

Scope {
    FontMetrics { id: previewFont; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
    WidgetEndpoint {
        name: "clipboard"
        openAction: screenName => { popup.screen = Widgets.screenFor(screenName); popup.open() }
        closeAction: () => popup.close()
    }
    StyledPopup {
        id: popup
        popupName: "clipboard"
        popupWidth: Sizing.clipboardWidth
        popupHeight: Sizing.clipboardHeight
        alignment: Qt.AlignTop | Qt.AlignRight
        topMargin: ScreenLayout.barPopupTop
        rightMargin: Spacing.barRightMargin
        padding: Spacing.sm
        property bool confirmClear: false
        property string selectedEntryId: ""
        property int selectedEntryIndex: 0
        readonly property var results: Clipboard.entries.filter(entry => search.text.trim().toLocaleLowerCase().split(/\s+/).every(word => entry.preview.toLocaleLowerCase().includes(word)))
        // Replacing a ListView model resets its index. Restore by ID after that reset.
        onResultsChanged: Qt.callLater(restoreSelection)
        onOpened: {
            confirmClear = false
            search.clear()
            selectEntry(0)
            Clipboard.refresh()
            Qt.callLater(() => search.forceActiveFocus())
        }
        onDismissed: Widgets.closed("clipboard")
        function selectEntry(index: int) {
            const next = results.length ? Math.max(0, Math.min(index, results.length - 1)) : -1
            selectedEntryIndex = next
            selectedEntryId = next >= 0 ? results[next].id : ""
            list.currentIndex = next
            if (next >= 0) list.positionViewAtIndex(next, ListView.Contain)
        }
        function restoreSelection() {
            const index = results.findIndex(entry => entry.id === selectedEntryId)
            selectEntry(index >= 0 ? index : selectedEntryIndex)
        }
        function moveSelection(delta: int) {
            if (!results.length) return
            selectEntry((Math.max(0, list.currentIndex) + delta + results.length) % results.length)
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
        Connections { target: Clipboard; function onCopied() { if (popup.isOpen) popup.close() } }
        Timer { interval: Theme.clipboardPollInterval; running: popup.isOpen; repeat: true; onTriggered: Clipboard.refresh() }
        ColumnLayout {
            anchors.fill: parent
            spacing: Spacing.sm
            RowLayout {
                Layout.fillWidth: true
                spacing: Spacing.md
                Text {
                    Layout.fillWidth: true
                    text: "Clipboard"
                    color: Colors.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.weight: Theme.headingFontWeight
                }
                Text {
                    text: search.text.trim() ? popup.results.length + " matches" : Clipboard.entries.length + " items"
                    color: Colors.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
            TextField {
                id: search
                Layout.fillWidth: true
                placeholderText: "Search your clipboard…"
                placeholderTextColor: Colors.textMuted
                selectionColor: Colors.primaryContainer
                selectedTextColor: Colors.onPrimaryContainer
                padding: Spacing.sm
                color: Colors.text
                font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                background: StyledContainer {
                    color: Colors.surfaceContainerLow
                    radius: Theme.radiusSmall
                    border.width: Theme.borderWidth
                    border.color: search.activeFocus ? Colors.primary : Colors.border
                }
                onTextChanged: { popup.selectEntry(0); popup.confirmClear = false }
                Keys.priority: Keys.BeforeItem
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Down) popup.moveSelection(1)
                    else if (event.key === Qt.Key_Up) popup.moveSelection(-1)
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) popup.copySelected()
                    else if (event.key === Qt.Key_Delete && event.modifiers & Qt.ControlModifier) popup.deleteSelected()
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
            Text {
                Layout.fillWidth: true
                visible: Clipboard.error !== ""
                text: Clipboard.error
                wrapMode: Text.Wrap
                color: Colors.error
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }
            ListView {
                boundsBehavior: Flickable.StopAtBounds
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 0
                implicitWidth: count ? Math.max(Sizing.dropdownMinWidth, ...popup.results.map(entry =>
                    previewFont.advanceWidth(String(entry.preview).replace(/\s+/g, " ").trim())
                    + Sizing.clipboardTypeWidth + Sizing.widgetHeight + Spacing.sm * 4 + Sizing.scrollBarWidth + Spacing.xs))
                    : emptyState.implicitWidth
                implicitHeight: Math.max(1, count) * Sizing.clipboardRowHeight + Math.max(0, count - 1) * spacing
                clip: true
                spacing: Spacing.xs
                model: popup.results
                currentIndex: count ? 0 : -1
                ScrollBar.vertical: StyledScrollBar {}
                delegate: StyledContainer {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool selected: ListView.isCurrentItem
                    readonly property string preview: String(modelData.preview).replace(/\s+/g, " ").trim()
                    readonly property var imageInfo: modelData.binary ? preview.match(/binary data (.+?) (png|jpg|jpeg|webp|gif|bmp) (\d+)x(\d+)/i) : null
                    readonly property string kind: imageInfo ? "IMG" : modelData.binary ? "FILE" : /^https?:\/\//i.test(preview) ? "LINK" : preview.startsWith("/") ? "PATH" : /^<(?:!doctype|html|meta|div|span)\b/i.test(preview) ? "HTML" : "TEXT"
                    readonly property string displayPreview: imageInfo
                        ? imageInfo[2].toUpperCase() + " image · " + imageInfo[3] + " × " + imageInfo[4] + " · " + imageInfo[1]
                        : modelData.binary ? preview.replace(/^\[\[\s*binary data\s*/, "File · ").replace(/\s*\]\]$/, "") : preview
                    width: list.width - Sizing.scrollBarWidth - Spacing.xs
                    height: Sizing.clipboardRowHeight
                    radius: Theme.radiusSmall
                    color: selected ? Colors.primaryContainer : copyButton.hovered || removeButton.hovered ? Colors.surfaceContainerHigh : "transparent"
                    border.width: copyButton.visualFocus ? Theme.borderWidth : Theme.borderNone
                    border.color: Colors.primary
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
                            contentItem: RowLayout {
                                spacing: Spacing.sm
                                StyledContainer {
                                    Layout.preferredWidth: Sizing.clipboardTypeWidth
                                    Layout.preferredHeight: Sizing.clipboardTypeHeight
                                    color: row.selected ? Colors.surfaceContainerHigh : Colors.surfaceContainerLow
                                    radius: Theme.radiusSmall
                                    border.width: Theme.borderNone
                                    Text {
                                        anchors.centerIn: parent
                                        text: row.kind
                                        color: Colors.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeSmall
                                        font.weight: Theme.headingFontWeight
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: row.displayPreview
                                    textFormat: Text.PlainText
                                    wrapMode: Text.NoWrap
                                    maximumLineCount: 1
                                    elide: Text.ElideRight
                                    color: row.selected ? Colors.onPrimaryContainer : Colors.text
                                    font.weight: Theme.fontWeight
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                        StyledIconButton {
                            id: removeButton
                            iconName: "trash"
                            tint: hovered ? Colors.onErrorContainer : Colors.textMuted
                            Layout.preferredWidth: Sizing.widgetHeight
                            Layout.preferredHeight: Sizing.widgetHeight
                            enabled: !Clipboard.busy
                            Accessible.name: "Remove clipboard entry"
                            onClicked: popup.removeEntry(row.modelData.id)
                            BarToolTip { target: removeButton; hovered: removeButton.hovered; text: "Remove entry · Ctrl+Delete" }
                            background: StyledContainer {
                                color: removeButton.hovered ? Colors.errorContainer : "transparent"
                                radius: Theme.radiusSmall
                                border.width: removeButton.visualFocus ? Theme.borderWidth : Theme.borderNone
                                border.color: Colors.primary
                            }
                        }
                    }
                }
                Text { id: emptyState; anchors.centerIn: parent; width: parent.width; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.Wrap; visible: list.count === 0; text: Clipboard.busy ? "Loading clipboard history…" : search.text ? "No matching entries" : "Your clipboard history is empty"; color: Colors.textMuted; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
            }
        }
    }
}

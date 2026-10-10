import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components.containers
import qs.config
import qs.services

// Shared presentation; owning widgets supply counts, actions and key behavior.
Item {
    id: root
    required property string title
    property string countText: ""
    property alias searchText: search.text
    property alias placeholderText: search.placeholderText
    readonly property alias searchField: search
    default property alias actions: actionRow.data
    signal searchKeyPressed(var event)
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight
    function focusSearch() { search.forceActiveFocus() }
    function clearSearch() { search.clear() }

    property RowLayout layout: RowLayout {
        parent: root
        anchors.fill: parent
        spacing: Spacing.md
        Text {
            text: root.title
            textFormat: Text.PlainText
            color: Colors.text
            font.family: Theme.headingFontFamily
            font.weight: Theme.headingFontWeight
            font.pixelSize: Theme.fontSizeLarge
        }
        TextField {
            id: search
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            placeholderText: "Search…"
            placeholderTextColor: Colors.textMuted
            selectionColor: Colors.primaryContainer
            selectedTextColor: Colors.onPrimaryContainer
            Accessible.name: "Search " + root.title.toLowerCase()
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
            Keys.priority: Keys.BeforeItem
            Keys.onPressed: event => {
                event.accepted = false
                root.searchKeyPressed(event)
            }
        }
        Text {
            visible: root.countText !== ""
            text: root.countText
            textFormat: Text.PlainText
            color: Colors.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
        RowLayout {
            id: actionRow
            visible: children.length > 0
            spacing: Spacing.xs
        }
    }
}

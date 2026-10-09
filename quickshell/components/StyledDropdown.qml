pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell as QS
import Quickshell.Wayland
import qs.components.containers
import qs.config
import qs.services

// One explicit open state avoids ComboBox focus/grab changes closing the menu.
Item {
    id: root
    property var model: []
    property string textRole: ""
    property int currentIndex: -1
    readonly property int count: model ? model.length : 0
    readonly property string currentText: {
        const entry = model && currentIndex >= 0 ? model[currentIndex] : undefined
        return entry === undefined ? "" : textRole ? String(entry[textRole] || "") : String(entry)
    }
    property string displayText: currentText
    property font font: Qt.font({ family: Theme.fontFamily, pixelSize: Theme.fontSizeSmall, weight: Theme.fontWeight })
    signal activated(int index)
    implicitWidth: Sizing.dropdownMinWidth
    implicitHeight: Sizing.dropdownHeight
    component DropdownState: QtObject {
        property bool visible: false
        function open() {
            visible = true
            choices.currentIndex = root.currentIndex >= 0 ? root.currentIndex : 0
            Qt.callLater(() => menuContent.forceActiveFocus())
        }
        function close() { visible = false }
    }
    property DropdownState popup: DropdownState {}
    StyledButton {
        id: trigger
        anchors.fill: parent
        text: root.displayText
        Accessible.name: root.Accessible.name || root.displayText
        font: root.font
        highlightInteractions: false
        leftPadding: Spacing.sm
        rightPadding: Spacing.sm * 2 + Sizing.dropdownIndicatorSize
        onClicked: { if (root.popup.visible) root.popup.close(); else root.popup.open() }
        Keys.onDownPressed: root.popup.open()
        Keys.onUpPressed: root.popup.open()
        contentItem: Text {
            text: trigger.text
            textFormat: Text.PlainText
            font: root.font
            color: root.enabled ? Colors.text : Colors.textMuted
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        ShellIcon {
            x: parent.width - width - Spacing.sm
            y: (parent.height - height) / 2
            width: Sizing.dropdownIndicatorSize
            height: Sizing.dropdownIndicatorSize
            kind: root.popup.visible ? "chevron-up" : "chevron-down"
            tint: Colors.textMuted
        }
    }
    function choose(index: int) {
        if (index < 0 || index >= count) return
        activated(index)
        popup.close()
        trigger.forceActiveFocus()
    }
    QS.PanelWindow {
        id: menu
        screen: root.QsWindow.window ? root.QsWindow.window.screen : null
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: QS.ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        // Keep topbar actions reachable while a selection menu is open.
        WlrLayershell.keyboardFocus: !root.popup.visible ? WlrKeyboardFocus.None
            : barInputHole.pointerInside ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.Exclusive
        color: "transparent"
        readonly property point origin: {
            const host = root.QsWindow.window
            const point = host ? root.mapToItem(host.contentItem, 0, root.height + Spacing.xs) : Qt.point(0, 0)
            return Qt.point(Math.max(0, Math.min(point.x, width - root.width)), Math.min(point.y, height - menuHeight))
        }
        readonly property real menuHeight: Math.min(Sizing.dropdownMaxHeight, root.count * Sizing.dropdownRowHeight + Spacing.xs * 2)
        mask: QS.Region {
            width: root.popup.visible ? menu.width : 0
            height: root.popup.visible ? menu.height : 0
            BarInputHole { id: barInputHole; screen: menu.screen; width: menu.width }
        }
        MouseArea { anchors.fill: parent; onPressed: root.popup.close() }
        property real progress: root.popup.visible ? 1 : 0
        visible: root.popup.visible || progress > 0
        onVisibleChanged: { if (!visible && root.popup.visible) root.popup.close() }
        Behavior on progress {
            NumberAnimation {
                duration: !Animations.enabled ? 0 : root.popup.visible ? Animations.expandDuration : Animations.collapseDuration
                easing.type: root.popup.visible ? Animations.expandEasing : Animations.collapseEasing
            }
        }
        StyledContainer {
            id: menuContent
            x: menu.origin.x
            y: menu.origin.y
            width: root.width
            height: menu.menuHeight
            color: Colors.panel
            radius: Theme.radiusSmall
            highlightOpacity: 0
            border.width: Theme.borderWidth
            border.color: Colors.border
            opacity: menu.progress
            enabled: root.popup.visible
            focus: true
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Down) choices.currentIndex = Math.min(root.count - 1, choices.currentIndex + 1)
                else if (event.key === Qt.Key_Up) choices.currentIndex = Math.max(0, choices.currentIndex - 1)
                else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) root.choose(choices.currentIndex)
                else if (event.key === Qt.Key_Escape || event.key === Qt.Key_Tab) root.popup.close()
                else return
                choices.positionViewAtIndex(choices.currentIndex, ListView.Contain)
                event.accepted = true
            }
            ListView {
                id: choices
                anchors.fill: parent
                anchors.margins: Spacing.xs
                clip: true
                model: root.model
                ScrollBar.vertical: StyledScrollBar {}
                delegate: StyledButton {
                    id: option
                    required property var modelData
                    required property int index
                    width: choices.width
                    height: Sizing.dropdownRowHeight
                    text: root.textRole ? String(modelData[root.textRole] || "") : String(modelData)
                    highlightInteractions: false
                    padding: Spacing.sm
                    topPadding: Spacing.xs
                    bottomPadding: Spacing.xs
                    onClicked: root.choose(index)
                    onHoveredChanged: { if (hovered) choices.currentIndex = index }
                    background: StyledContainer {
                        radius: Theme.radiusNone
                        highlightOpacity: 0
                        color: choices.currentIndex === option.index ? Colors.surfaceContainerHigh : "transparent"
                        border.width: option.visualFocus ? Theme.borderSelectedWidth : Theme.borderNone
                        border.color: Colors.primary
                    }
                    contentItem: RowLayout {
                        spacing: Spacing.sm
                        Text {
                            Layout.fillWidth: true
                            text: option.text
                            textFormat: Text.PlainText
                            font: root.font
                            color: Colors.text
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                        ShellIcon {
                            kind: "check"
                            tint: Colors.textMuted
                            opacity: root.currentIndex === option.index ? 1 : 0
                            Layout.preferredWidth: Sizing.dropdownIndicatorSize
                            Layout.preferredHeight: Sizing.dropdownIndicatorSize
                        }
                    }
                }
            }
        }
    }
}

pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import qs.components.containers
import qs.config
import qs.services

// One explicit open state avoids ComboBox focus/grab changes closing the menu.
Item {
    id: root
    readonly property bool windowedHost: !root.QsWindow.window && !!root.Window.window
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
    FontMetrics { id: displayFont; font: root.font }
    implicitWidth: Math.max(Sizing.dropdownMinWidth, displayFont.advanceWidth(displayText) + Spacing.sm * 3 + Sizing.dropdownIndicatorSize)
    implicitHeight: Sizing.dropdownHeight
    component DropdownState: QtObject {
        property bool visible: false
        function open() {
            visible = true
            windowChoices.currentIndex = root.currentIndex >= 0 ? root.currentIndex : 0
            Qt.callLater(() => { if (root.windowedHost) windowChoices.forceActiveFocus(); else desktopHost.item.focusMenu() })
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
    Component {
        id: dropdownDelegate
        StyledButton {
            id: option
            required property var modelData
            required property int index
            readonly property ListView list: ListView.view
            width: list.width
            height: Sizing.dropdownRowHeight
            text: root.textRole ? String(modelData[root.textRole] || "") : String(modelData)
            highlightInteractions: false
            padding: Spacing.sm
            topPadding: Spacing.xs
            bottomPadding: Spacing.xs
            onClicked: root.choose(index)
            onHoveredChanged: { if (hovered) option.list.currentIndex = index }
            background: StyledContainer {
                radius: Theme.radiusNone
                highlightOpacity: 0
                color: option.list.currentIndex === option.index ? Colors.surfaceContainerHigh : "transparent"
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
    Popup {
        id: windowMenu
        parent: root
        // Normal windows can clip a bottom-corner menu. Open above the trigger
        // when the remaining space below it cannot hold the popup.
        y: {
            const host = root.Window.window
            const top = host ? root.mapToItem(host.contentItem, 0, 0).y : 0
            return host && top + root.height + Spacing.xs + height > host.height
                ? -height - Spacing.xs : root.height + Spacing.xs
        }
        width: root.width
        height: Math.min(Sizing.dropdownMaxHeight, root.count * Sizing.dropdownRowHeight)
        padding: 0
        visible: root.windowedHost && root.popup.visible
        onClosed: root.popup.close()
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: null
        enter: Transition {
            NumberAnimation { target: windowSurface; property: "revealProgress"; from: 0; to: 1; duration: Animations.enabled ? Animations.expandDuration : 0; easing.type: Animations.expandEasing }
        }
        exit: Transition {
            NumberAnimation { target: windowSurface; property: "revealProgress"; from: 1; to: 0; duration: Animations.enabled ? Animations.collapseDuration : 0; easing.type: Animations.collapseEasing }
        }
        contentItem: Item {
            StyledContainer {
                id: windowMask
                width: windowSurface.width
                height: windowSurface.height
                radius: windowSurface.radius
                color: "white"
                highlightOpacity: 0
                border.width: Theme.borderNone
                visible: false
                layer.enabled: true
            }
            RevealingContainer {
                id: windowSurface
                width: parent.width
                fullHeight: windowMenu.availableHeight
                revealOrigin: windowMenu.y < 0 ? 1 : 0
                y: (fullHeight - height) * revealOrigin
                radius: Theme.radiusSmall
                enabled: root.popup.visible
                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: windowMask
                    maskThresholdMin: 0.5
                    maskSpreadAtMin: 1.0
                }
                ListView {
                    id: windowChoices
                    width: parent.width
                    height: windowSurface.fullHeight
                    y: windowSurface.contentOffsetY
                    clip: true
                    model: root.model
                    ScrollBar.vertical: StyledScrollBar {}
                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Down) currentIndex = Math.min(root.count - 1, currentIndex + 1)
                        else if (event.key === Qt.Key_Up) currentIndex = Math.max(0, currentIndex - 1)
                        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) root.choose(currentIndex)
                        else if (event.key === Qt.Key_Escape || event.key === Qt.Key_Tab) root.popup.close()
                        else return
                        positionViewAtIndex(currentIndex, ListView.Contain)
                        event.accepted = true
                    }
                    delegate: dropdownDelegate
                }
            }
        }
    }

    // Load the layer-shell host only for desktop widgets. Cage and preview
    // windows use the in-window host without requiring layer-shell support.
    Loader {
        id: desktopHost
        active: !root.windowedHost
        function loadHost() {
            if (active && !source.toString())
                setSource(Qt.resolvedUrl("StyledDropdownPanel.qml"), { dropdown: root, optionDelegate: dropdownDelegate })
        }
        onActiveChanged: {
            if (active) loadHost()
            else source = ""
        }
        Component.onCompleted: loadHost()
    }
}

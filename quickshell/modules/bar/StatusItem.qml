import QtQuick
import qs.components
import qs.components.containers
import QtQuick.Controls
import qs.services
import qs.config

StyledButton {
    id: root
    property real batteryLevel: 100
    property string statusIcon: ""
    property string label: ""
    property color tint: Colors.text
    property bool interactive: false
    property bool revealPercentage: false
    readonly property real iconSlotWidth: Sizing.barIconSize + Spacing.sm
    readonly property real compactWidth: iconSlotWidth
        + (!revealPercentage && label !== "" ? Spacing.xs + value.implicitWidth : 0)
    readonly property real percentageWidth: revealPercentage && label !== "" ? Spacing.xs + content.valueWidth : 0
    readonly property real revealedWidth: percentageWidth * revealProgress
    // Read-only indicators still need hover input to reveal their values.
    enabled: interactive || label !== ""
    pointerCursorEnabled: interactive
    focusPolicy: interactive ? Qt.StrongFocus : Qt.NoFocus
    readonly property bool revealing: revealPercentage && label !== "" && (hovered || visualFocus)
    property real revealProgress: revealing ? 1 : 0
    Behavior on revealProgress {
        NumberAnimation {
            duration: !Animations.enabled ? 0 : root.revealing ? Animations.revealDuration : Animations.collapseDuration
            easing.type: root.revealing ? Animations.revealEasing : Animations.collapseEasing
        }
    }
    highlightInteractions: false
    Accessible.name: label || statusIcon
    scrollActionEnabled: interactive
    implicitWidth: compactWidth + percentageWidth
    // The bar positions fixed content with transforms; this extent is for input.
    width: compactWidth + revealedWidth
    implicitHeight: Sizing.widgetHeight
    padding: 0
    background: StyledContainer {
        radius: Theme.radiusSmall
        color: "transparent"
        border.width: root.visualFocus ? Theme.borderSelectedWidth : Theme.borderNone
        border.color: Colors.primary
    }
    contentItem: Item {
        id: content
        // Icon and text keep a stable layout while the input extent reveals the value.
        implicitWidth: root.compactWidth + root.percentageWidth
        implicitHeight: Math.max(indicator.implicitHeight, value.implicitHeight)
        readonly property real valueWidth: Math.max(metrics.advanceWidth("100%"), value.implicitWidth)
        clip: true
        FontMetrics { id: metrics; font: value.font }
        BarIcon {
            id: indicator
            visible: root.statusIcon !== ""
            kind: root.statusIcon
            tint: root.tint
            batteryLevel: root.batteryLevel
            anchors.verticalCenter: parent.verticalCenter
            x: (root.iconSlotWidth - width) / 2
        }
        Text {
            id: value
            visible: root.label !== ""
            text: root.label
            color: root.tint
            anchors.verticalCenter: parent.verticalCenter
            x: root.iconSlotWidth - Spacing.sm / 2 + Spacing.xs
            transform: Translate { x: root.revealPercentage ? Spacing.popupSlideOffset * (1 - root.revealProgress) : 0 }
            opacity: root.revealPercentage ? root.revealProgress : 1
            font.weight: Theme.fontWeight; font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.features: { "tnum": 1 }
        }
    }
}

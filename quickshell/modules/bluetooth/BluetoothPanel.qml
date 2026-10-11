pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth as BT
import qs.components
import qs.components.containers
import qs.config
import qs.services

Scope {
    WidgetEndpoint {
        name: "bluetooth"
        openAction: screenName => { popup.screen = Widgets.screenFor(screenName); popup.open() }
        closeAction: () => popup.close()
    }
    FontMetrics { id: deviceFont; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
    ExpandingPopup {
        id: popup
        anchorName: "bluetooth"
        expansionMode: "below"
        popupWidth: Sizing.bluetoothPanelWidth
        popupHeight: Sizing.bluetoothPanelHeight
        onDismissed: Widgets.closed("bluetooth")
        Binding { target: Bluetooth; property: "menuOpen"; value: popup.expanded }
        Connections {
            target: Bluetooth
            function onPromptChanged() {
                pairingCode.clear()
                if (Bluetooth.prompt && (Bluetooth.prompt.kind === "pin" || Bluetooth.prompt.kind === "passkey"))
                    Qt.callLater(() => pairingCode.forceActiveFocus())
            }
        }
        ColumnLayout {
            anchors.fill: parent
            spacing: Spacing.sm
            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: "Bluetooth"
                    color: Colors.text
                    font.family: Theme.headingFontFamily
                    font.weight: Theme.headingFontWeight
                    font.pixelSize: Theme.fontSizeLarge
                }
                StyledButton {
                    text: Bluetooth.enabled ? "Bluetooth on" : "Bluetooth off"
                    visible: Bluetooth.available
                    enabled: !Bluetooth.blocked && !Bluetooth.powerChanging
                    checkable: true
                    checked: Bluetooth.enabled
                    Accessible.name: Bluetooth.enabled ? "Turn Bluetooth off" : "Turn Bluetooth on"
                    onClicked: Bluetooth.setEnabled(!Bluetooth.enabled)
                }
            }
            StyledContainer {
                Layout.fillWidth: true
                implicitWidth: connectionInfo.implicitWidth + Spacing.sm * 2
                implicitHeight: connectionInfo.implicitHeight + Spacing.sm * 2
                radius: Theme.radiusSmall
                color: Colors.surfaceContainerHigh
                RowLayout {
                    id: connectionInfo
                    x: Spacing.sm
                    y: Spacing.sm
                    width: parent.width - Spacing.sm * 2
                    spacing: Spacing.sm
                    ShellIcon { kind: Bluetooth.icon; tint: Bluetooth.connectedDevices.length ? Colors.primary : Colors.textMuted }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Spacing.xs
                        Text {
                            Layout.fillWidth: true
                            text: Bluetooth.details
                            textFormat: Text.PlainText
                            elide: Text.ElideRight
                            color: Colors.text
                            font.family: Theme.fontFamily
                            font.weight: Theme.emphasisFontWeight
                            font.pixelSize: Theme.fontSizeSmall
                        }
                        Text {
                            Layout.fillWidth: true
                            text: Bluetooth.adapter ? Bluetooth.adapter.name + " · "
                                + (Bluetooth.powerChanging ? "Changing power…" : Bluetooth.discovering ? "Discovering devices…"
                                    : Bluetooth.connectedDevices.length ? Bluetooth.connectedDevices.length + " connected" : "No active connections")
                                : "Connect a Bluetooth adapter to get started"
                            textFormat: Text.PlainText
                            elide: Text.ElideRight
                            color: Colors.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: "Devices"
                    color: Colors.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
                StyledButton {
                    text: Bluetooth.scanRequested ? "Stop scanning" : "Scan"
                    enabled: Bluetooth.enabled && !Bluetooth.busy && !Bluetooth.powerChanging
                    flat: true
                    padding: Spacing.xs
                    onClicked: Bluetooth.toggleScan()
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 0
                implicitWidth: devices.count ? Math.max(Sizing.dropdownMinWidth,
                    ...Bluetooth.devices.map(device => deviceFont.advanceWidth(device.name || device.address)
                        + deviceFont.advanceWidth("Disconnect") + Sizing.barIconSize + Spacing.sm * 4 + Sizing.scrollBarWidth + Spacing.xs))
                    : emptyState.implicitWidth
                implicitHeight: devices.count ? devices.count * Sizing.bluetoothRowHeight + Math.max(0, devices.count - 1) * Spacing.xs
                    : emptyState.implicitHeight + Spacing.sm * 2
                ListView {
                    id: devices
                    anchors.fill: parent
                    clip: true
                    spacing: Spacing.xs
                    model: Bluetooth.enabled ? Bluetooth.devices : []
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: StyledScrollBar {}
                    delegate: StyledButton {
                        id: option
                        required property var modelData
                        readonly property bool connected: !!modelData && modelData.connected
                        readonly property bool changing: !!modelData && (modelData.pairing || modelData.state === BT.BluetoothDeviceState.Connecting
                            || modelData.state === BT.BluetoothDeviceState.Disconnecting || Bluetooth.operationPath === modelData.dbusPath)
                        width: devices.width - Sizing.scrollBarWidth - Spacing.xs
                        height: Sizing.bluetoothRowHeight
                        enabled: !!modelData && !modelData.blocked && !Bluetooth.busy && !changing && Bluetooth.enabled
                        Accessible.name: modelData ? (modelData.name || modelData.address) + (connected ? ", disconnect" : ", connect") : "Bluetooth device"
                        highlightInteractions: false
                        padding: Spacing.sm
                        onClicked: Bluetooth.selectDevice(modelData)
                        background: StyledContainer {
                            radius: Theme.radiusSmall
                            color: option.connected ? Colors.primaryContainer : option.hovered ? Colors.surfaceContainerHigh : "transparent"
                            border.width: option.visualFocus ? Theme.borderSelectedWidth : Theme.borderNone
                            border.color: Colors.primary
                        }
                        contentItem: RowLayout {
                            spacing: Spacing.sm
                            ShellIcon { kind: "bluetooth"; tint: option.connected ? Colors.onPrimaryContainer : Colors.textMuted }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Spacing.xs
                                Text {
                                    Layout.fillWidth: true
                                    text: option.modelData ? option.modelData.name || option.modelData.address : ""
                                    textFormat: Text.PlainText
                                    elide: Text.ElideRight
                                    color: option.connected ? Colors.onPrimaryContainer : Colors.text
                                    font.family: Theme.fontFamily
                                    font.weight: Theme.emphasisFontWeight
                                    font.pixelSize: Theme.fontSizeSmall
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: !option.modelData ? "" : option.changing ? (option.modelData.pairing ? "Pairing…" : "Working…")
                                        : option.connected ? "Connected" : option.modelData.blocked ? "Blocked" : option.modelData.paired ? "Paired" : "Pair and connect"
                                    color: option.connected ? Colors.onPrimaryContainer : Colors.textMuted
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize
                                }
                            }
                            Text {
                                text: option.changing ? "…" : option.connected ? "Disconnect" : "Connect"
                                color: option.connected ? Colors.onPrimaryContainer : Colors.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                            }
                        }
                    }
                }
                Text {
                    id: emptyState
                    anchors.centerIn: parent
                    width: parent.width
                    visible: devices.count === 0
                    text: !Bluetooth.available ? "No Bluetooth adapter available" : Bluetooth.blocked ? "Bluetooth is blocked by the hardware switch"
                        : !Bluetooth.enabled ? "Bluetooth is off" : Bluetooth.discovering ? "Looking for devices…\nMake your device discoverable to pair it."
                            : "No devices found. Start a scan to discover devices."
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    color: Colors.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
            StyledContainer {
                Layout.fillWidth: true
                visible: Bluetooth.prompt !== null
                implicitWidth: pairing.implicitWidth + Spacing.sm * 2
                implicitHeight: pairing.implicitHeight + Spacing.sm * 2
                radius: Theme.radiusSmall
                color: Colors.surfaceContainerHigh
                ColumnLayout {
                    id: pairing
                    x: Spacing.sm
                    y: Spacing.sm
                    width: parent.width - Spacing.sm * 2
                    spacing: Spacing.sm
                    Text {
                        Layout.fillWidth: true
                        text: !Bluetooth.prompt ? "" : Bluetooth.prompt.kind === "confirm" ? "Does " + Bluetooth.prompt.code + " match the code on " + Bluetooth.operationName + "?"
                            : Bluetooth.prompt.kind === "display" ? "Enter " + Bluetooth.prompt.code + " on " + Bluetooth.operationName + ", then press Enter on that device."
                            : Bluetooth.prompt.kind === "authorize" ? "Allow pairing with " + Bluetooth.operationName + "?"
                            : "Enter the " + (Bluetooth.prompt.kind === "pin" ? "PIN" : "passkey") + " for " + Bluetooth.operationName
                        textFormat: Text.PlainText
                        wrapMode: Text.Wrap
                        color: Colors.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                    TextField {
                        id: pairingCode
                        Layout.fillWidth: true
                        visible: !!Bluetooth.prompt && (Bluetooth.prompt.kind === "pin" || Bluetooth.prompt.kind === "passkey")
                        maximumLength: Bluetooth.prompt && Bluetooth.prompt.kind === "passkey" ? 6 : 16
                        placeholderText: Bluetooth.prompt && Bluetooth.prompt.kind === "pin" ? "PIN" : "Passkey"
                        Accessible.name: placeholderText
                        color: Colors.text
                        placeholderTextColor: Colors.textMuted
                        selectionColor: Colors.primaryContainer
                        selectedTextColor: Colors.onPrimaryContainer
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        padding: Spacing.sm
                        background: StyledContainer {
                            radius: Theme.radiusSmall
                            color: Colors.surfaceContainer
                            border.width: pairingCode.activeFocus ? Theme.borderSelectedWidth : Theme.borderWidth
                            border.color: pairingCode.activeFocus ? Colors.primary : Colors.border
                        }
                        onAccepted: if (text.length) Bluetooth.respond(true, text)
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Item { Layout.fillWidth: true }
                        StyledButton { text: "Cancel"; flat: true; onClicked: Bluetooth.cancel() }
                        StyledButton {
                            text: pairingCode.visible ? "Pair" : "Confirm"
                            visible: !!Bluetooth.prompt && Bluetooth.prompt.kind !== "display"
                            enabled: !pairingCode.visible || pairingCode.text.length > 0
                            onClicked: Bluetooth.respond(true, pairingCode.text)
                        }
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                visible: Bluetooth.busy || Bluetooth.error !== ""
                Text {
                    Layout.fillWidth: true
                    text: Bluetooth.error || (Bluetooth.operationAction === "disconnect" ? "Disconnecting from " : "Connecting to ") + Bluetooth.operationName + "…"
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    color: Bluetooth.error ? Colors.error : Colors.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }
                StyledButton { text: "Cancel"; visible: Bluetooth.busy && Bluetooth.prompt === null; flat: true; onClicked: Bluetooth.cancel() }
            }
        }
    }
}

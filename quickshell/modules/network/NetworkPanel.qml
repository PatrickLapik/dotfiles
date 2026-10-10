pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.components.containers
import qs.config
import qs.services

Scope {
    FontMetrics { id: networkFont; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
    WidgetEndpoint {
        name: "network"
        openAction: screenName => { popup.screen = Widgets.screenFor(screenName); popup.open() }
        closeAction: () => popup.close()
    }
    ExpandingPopup {
        id: popup
        anchorName: "network"
        expansionMode: "below"
        popupWidth: Sizing.networkPanelWidth
        popupHeight: Sizing.networkPanelHeight
        onDismissed: { password.clear(); Widgets.closed("network") }
        Binding { target: Network; property: "menuOpen"; value: popup.expanded }
        Connections {
            target: Network
            function onPasswordNetworkChanged() {
                password.clear()
                if (Network.passwordNetwork && popup.expanded) Qt.callLater(() => password.forceActiveFocus())
            }
        }
        ColumnLayout {
            anchors.fill: parent
            spacing: Spacing.sm
            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: "Network"
                    color: Colors.text
                    font.family: Theme.headingFontFamily
                    font.weight: Theme.headingFontWeight
                    font.pixelSize: Theme.fontSizeLarge
                }
                StyledButton {
                    text: Network.wifiEnabled ? "Wi-Fi on" : "Wi-Fi off"
                    visible: Network.wifiAvailable
                    enabled: !Network.busy && Network.wifiHardwareEnabled
                    checkable: true
                    checked: Network.wifiEnabled
                    Accessible.name: Network.wifiEnabled ? "Turn Wi-Fi off" : "Turn Wi-Fi on"
                    onClicked: Network.setWifiEnabled(!Network.wifiEnabled)
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
                    ShellIcon { kind: Network.icon; tint: Network.connected ? Colors.primary : Colors.textMuted }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Spacing.xs
                        Text {
                            Layout.fillWidth: true
                            text: Network.name
                            textFormat: Text.PlainText
                            elide: Text.ElideRight
                            color: Colors.text
                            font.family: Theme.fontFamily
                            font.weight: Theme.emphasisFontWeight
                            font.pixelSize: Theme.fontSizeSmall
                        }
                        Text {
                            Layout.fillWidth: true
                            text: !Network.connected ? "No active connection" : (Network.wireless ? "Wi-Fi" : "Ethernet") + " · " + Network.device.name
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
                    text: "Nearby Wi-Fi"
                    color: Colors.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
                StyledButton {
                    text: "Disconnect"
                    visible: Network.wifiAvailable && Network.wifiDevice.connected
                    enabled: !Network.busy
                    flat: true
                    padding: Spacing.xs
                    onClicked: Network.disconnectWifi()
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 0
                implicitWidth: networks.count ? Math.max(Sizing.dropdownMinWidth,
                    ...Network.nearbyNetworks.map(network => networkFont.advanceWidth(network.name)
                        + networkFont.advanceWidth("100%") + Sizing.barIconSize + Spacing.sm * 4 + Sizing.scrollBarWidth + Spacing.xs))
                    : emptyState.implicitWidth
                implicitHeight: networks.count
                    ? networks.count * Sizing.networkRowHeight + Math.max(0, networks.count - 1) * Spacing.xs
                    : emptyState.implicitHeight + Spacing.sm * 2
                ListView {
                    id: networks
                    anchors.fill: parent
                    clip: true
                    spacing: Spacing.xs
                    model: Network.nearbyNetworks
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: StyledScrollBar {}
                    delegate: StyledButton {
                        id: option
                        required property var modelData
                        width: networks.width - Sizing.scrollBarWidth - Spacing.xs
                        height: Sizing.networkRowHeight
                        enabled: !Network.busy && !modelData.stateChanging
                        Accessible.name: modelData.name + (modelData.connected ? ", connected" : ", connect")
                        highlightInteractions: false
                        padding: Spacing.sm
                        onClicked: Network.selectWifi(modelData)
                        background: StyledContainer {
                            radius: Theme.radiusSmall
                            color: option.modelData.connected ? Colors.primaryContainer
                                : option.hovered ? Colors.surfaceContainerHigh : "transparent"
                            border.width: option.visualFocus ? Theme.borderSelectedWidth : Theme.borderNone
                            border.color: Colors.primary
                        }
                        contentItem: RowLayout {
                            spacing: Spacing.sm
                            ShellIcon { kind: "wifi"; tint: option.modelData.connected ? Colors.onPrimaryContainer : Colors.textMuted }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Spacing.xs
                                Text {
                                    Layout.fillWidth: true
                                    text: option.modelData.name
                                    textFormat: Text.PlainText
                                    elide: Text.ElideRight
                                    color: option.modelData.connected ? Colors.onPrimaryContainer : Colors.text
                                    font.family: Theme.fontFamily
                                    font.weight: Theme.emphasisFontWeight
                                    font.pixelSize: Theme.fontSizeSmall
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: option.modelData.connected ? "Connected" : option.modelData.stateChanging ? "Connecting…"
                                        : option.modelData.known ? "Saved" : Network.usesPassword(option.modelData) ? "Password required" : ""
                                    visible: text !== ""
                                    color: option.modelData.connected ? Colors.onPrimaryContainer : Colors.textMuted
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize
                                }
                            }
                            Text {
                                text: Math.round(option.modelData.signalStrength * 100) + "%"
                                color: option.modelData.connected ? Colors.onPrimaryContainer : Colors.textMuted
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
                    visible: networks.count === 0
                    text: !Network.wifiAvailable ? "No Wi-Fi adapter available"
                        : !Network.wifiHardwareEnabled ? "Wi-Fi is blocked by the hardware switch"
                        : !Network.wifiEnabled ? "Wi-Fi is off" : "Looking for nearby networks…"
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    color: Colors.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
            StyledContainer {
                Layout.fillWidth: true
                visible: Network.passwordNetwork !== null
                implicitWidth: credentials.implicitWidth + Spacing.sm * 2
                implicitHeight: credentials.implicitHeight + Spacing.sm * 2
                radius: Theme.radiusSmall
                color: Colors.surfaceContainerHigh
                ColumnLayout {
                    id: credentials
                    x: Spacing.sm
                    y: Spacing.sm
                    width: parent.width - Spacing.sm * 2
                    spacing: Spacing.sm
                    Text {
                        Layout.fillWidth: true
                        text: Network.passwordNetwork ? "Connect to " + Network.passwordNetwork.name : ""
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        color: Colors.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                    TextField {
                        id: password
                        Layout.fillWidth: true
                        echoMode: TextInput.Password
                        placeholderText: "Wi-Fi password"
                        Accessible.name: "Wi-Fi password"
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
                            border.width: password.activeFocus ? Theme.borderSelectedWidth : Theme.borderWidth
                            border.color: password.activeFocus ? Colors.primary : Colors.border
                        }
                        onAccepted: if (text.length > 0) Network.connectWithPassword(text)
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Item { Layout.fillWidth: true }
                        StyledButton { text: "Cancel"; flat: true; onClicked: Network.cancelPassword() }
                        StyledButton {
                            text: "Connect"
                            enabled: password.text.length > 0 && !Network.busy
                            onClicked: Network.connectWithPassword(password.text)
                        }
                    }
                }
            }
            Text {
                Layout.fillWidth: true
                visible: Network.busy || Network.error !== ""
                text: Network.busy ? "Connecting to " + Network.attemptNetwork.name + "…" : Network.error
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideRight
                color: Network.error ? Colors.error : Colors.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }
        }
    }
}

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking as Net
import qs.config

Singleton {
    id: root
    // Prefer connected Ethernet, then connected Wi-Fi.
    readonly property var device: Net.Networking.devices.values.find(d => d.connected && d.type === Net.DeviceType.Wired)
        || Net.Networking.devices.values.find(d => d.connected) || null
    readonly property bool connected: !!device
    readonly property bool wireless: !!device && device.type === Net.DeviceType.Wifi
    readonly property var connection: device ? device.networks.values.find(n => n.connected) : null
    readonly property string name: connection ? connection.name : device ? device.name : "Disconnected"
    readonly property string icon: !connected ? "offline" : wireless ? "wifi" : "ethernet"
    readonly property string details: !connected ? "Network disconnected" : (wireless ? "Wi-Fi · " : "Ethernet · ") + name + "\n" + device.name
    readonly property Net.WifiDevice wifiDevice: Net.Networking.devices.values.find(d => d.connected && d.type === Net.DeviceType.Wifi)
        || Net.Networking.devices.values.find(d => d.type === Net.DeviceType.Wifi) || null
    readonly property bool wifiAvailable: !!wifiDevice
    readonly property bool wifiEnabled: Net.Networking.wifiEnabled
    readonly property bool wifiHardwareEnabled: Net.Networking.wifiHardwareEnabled
    readonly property var liveNetworks: wifiDevice && wifiEnabled ? wifiDevice.networks.values
        .filter(network => network.name !== "")
        .slice().sort((a, b) => Number(b.connected) - Number(a.connected)
            || b.signalStrength - a.signalStrength || a.name.localeCompare(b.name)) : []
    // Cache plain data, never scan-owned QObjects that may disappear during a scan.
    readonly property alias nearbyNetworks: networkCache
    property var networkLastSeen: ({})
    ListModel { id: networkCache; dynamicRoles: true }

    function networkKey(network) { return JSON.stringify([network.name, network.security]) }
    function refreshNetworks() {
        if (!wifiDevice || !wifiEnabled || !wifiHardwareEnabled) {
            networkCache.clear()
            networkLastSeen = ({})
            return
        }
        const now = Date.now()
        const seen = new Set()
        for (const network of liveNetworks) {
            const key = networkKey(network)
            if (seen.has(key)) continue
            seen.add(key)
            networkLastSeen[key] = now
            const data = {
                key: key, name: network.name, security: network.security,
                connected: network.connected, known: network.known,
                stateChanging: network.stateChanging, signalStrength: network.signalStrength,
                available: true
            }
            let index = -1
            for (let i = 0; i < networkCache.count; ++i) {
                if (networkCache.get(i).networkData.key === key) { index = i; break }
            }
            if (index < 0) networkCache.append({networkData: data})
            else if (JSON.stringify(networkCache.get(index).networkData) !== JSON.stringify(data))
                networkCache.setProperty(index, "networkData", data)
        }
        for (let i = networkCache.count - 1; i >= 0; --i) {
            const data = networkCache.get(i).networkData
            if (seen.has(data.key)) continue
            if (now - networkLastSeen[data.key] >= Theme.networkCacheTimeout) {
                delete networkLastSeen[data.key]
                networkCache.remove(i)
            } else if (data.available) {
                networkCache.setProperty(i, "networkData", Object.assign({}, data, {
                    available: false, connected: false, stateChanging: false
                }))
            }
        }
    }
    onLiveNetworksChanged: refreshNetworks()
    onWifiDeviceChanged: {
        networkCache.clear()
        networkLastSeen = ({})
        refreshNetworks()
    }
    onWifiHardwareEnabledChanged: refreshNetworks()
    Component.onCompleted: refreshNetworks()
    Timer {
        interval: Theme.networkCacheRefreshInterval
        running: root.wifiAvailable && root.wifiEnabled && root.wifiHardwareEnabled
        repeat: true
        onTriggered: root.refreshNetworks()
    }
    property bool menuOpen: false
    property Net.WifiNetwork passwordNetwork: null
    property Net.WifiNetwork attemptNetwork: null
    property bool submittedPassword: false
    property string error: ""
    readonly property bool busy: attemptNetwork !== null

    Binding {
        target: root.wifiDevice
        property: "scannerEnabled"
        when: root.wifiDevice !== null
        value: root.wifiEnabled && root.wifiHardwareEnabled
        restoreMode: Binding.RestoreBindingOrValue
    }
    onMenuOpenChanged: if (!menuOpen) passwordNetwork = null
    onWifiEnabledChanged: {
        if (!wifiEnabled) passwordNetwork = null
        refreshNetworks()
    }

    function usesPassword(network) {
        return network && (network.security === Net.WifiSecurityType.WpaPsk
            || network.security === Net.WifiSecurityType.Wpa2Psk || network.security === Net.WifiSecurityType.Sae)
    }
    function setWifiEnabled(enabled: bool) {
        if (!busy && wifiAvailable && wifiHardwareEnabled) {
            error = ""
            Net.Networking.wifiEnabled = enabled
        }
    }
    function selectWifi(cachedNetwork) {
        const network = liveNetworks.find(candidate => networkKey(candidate) === cachedNetwork.key)

        if (!network || busy || network.stateChanging || !wifiEnabled) return
        error = ""
        passwordNetwork = null
        if (network.connected) return
        if (!network.known && usesPassword(network)) {
            passwordNetwork = network
            return
        }
        if (!network.known && network.security !== Net.WifiSecurityType.Open
            && network.security !== Net.WifiSecurityType.Owe) {
            error = "This network requires a connection profile. Configure it in your network settings first."
            return
        }
        submittedPassword = false
        attemptNetwork = network
        network.connect()
    }
    function connectWithPassword(password: string) {
        if (!passwordNetwork || busy || password.length === 0 || !wifiEnabled) return
        const network = passwordNetwork
        error = ""
        passwordNetwork = null
        submittedPassword = true
        attemptNetwork = network
        network.connectWithPsk(password)
    }
    function cancelPassword() { passwordNetwork = null; error = "" }
    function disconnectWifi() {
        if (busy || !wifiDevice || !wifiDevice.connected) return
        error = ""
        passwordNetwork = null
        wifiDevice.disconnect()
    }
    function connectionFailed(reason) {
        const network = attemptNetwork
        if (!network) return
        attemptNetwork = null
        if (reason === Net.ConnectionFailReason.NoSecrets && usesPassword(network)) {
            if (menuOpen) passwordNetwork = network
            error = submittedPassword ? "Authentication failed. Check the password and try again." : "Enter the Wi-Fi password to connect."
        } else error = "Could not connect: " + Net.ConnectionFailReason.toString(reason)
    }
    Connections {
        target: root.attemptNetwork
        function onConnectedChanged() {
            if (root.attemptNetwork && root.attemptNetwork.connected) {
                root.attemptNetwork = null
                root.error = ""
            }
        }
        function onConnectionFailed(reason) { root.connectionFailed(reason) }
    }
    Timer {
        interval: Theme.networkConnectionTimeout
        running: root.busy
        onTriggered: {
            root.attemptNetwork = null
            root.error = "Connection timed out. Try again."
        }
    }
}

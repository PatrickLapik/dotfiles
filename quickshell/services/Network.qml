pragma Singleton
import Quickshell
import Quickshell.Networking

Singleton {
    // Prefer connected Ethernet, then connected Wi-Fi.
    readonly property var device: Networking.devices.values.find(d => d.connected && d.type === DeviceType.Wired)
        || Networking.devices.values.find(d => d.connected) || null
    readonly property bool connected: !!device
    readonly property bool wireless: !!device && device.type === DeviceType.Wifi
    readonly property var connection: device ? device.networks.values.find(n => n.connected) : null
    readonly property string name: connection ? connection.name : device ? device.name : "Disconnected"
    readonly property string icon: !connected ? "offline" : wireless ? "wifi" : "ethernet"
    readonly property string details: !connected ? "Network disconnected" : (wireless ? "Wi-Fi · " : "Ethernet · ") + name + "\n" + device.name
}

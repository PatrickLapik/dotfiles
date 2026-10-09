pragma Singleton
import Quickshell
import Quickshell.Services.UPower
import qs.config

Singleton {
    readonly property bool hasBattery: UPower.devices.values.some(device => device.isLaptopBattery && device.isPresent)
    readonly property bool isLaptop: ShellConfig.deviceType === "laptop" || (ShellConfig.deviceType === "auto" && hasBattery)
    readonly property var battery: UPower.displayDevice
    readonly property bool showBattery: isLaptop && hasBattery && battery.ready
    readonly property int batteryPercent: Math.round(battery.percentage * 100)
    readonly property bool charging: battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.PendingCharge
    readonly property bool onBattery: UPower.onBattery
}

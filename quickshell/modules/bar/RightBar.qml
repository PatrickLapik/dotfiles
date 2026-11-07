import QtQuick
import Quickshell
import qs.components
import qs.services
import qs.config

Item {
    id: root
    property bool sectionHovered: false
    // Stable slots avoid running a RowLayout on each animation frame.
    readonly property var indicators: [bluetoothButton, brightnessButton, microphone,
        volumeButton, networkButton, batteryButton, bell]
    implicitWidth: extent(false)
    implicitHeight: Sizing.widgetHeight
    readonly property real visibleWidth: extent(true)

    function extent(animated) {
        let total = 0
        let count = 0
        for (const indicator of indicators) {
            if (!indicator.visible) continue
            total += animated ? indicator.compactWidth + indicator.revealedWidth : indicator.implicitWidth
            count++
        }
        return total + Math.max(0, count - 1) * Spacing.barStatusGap
    }

    function slotX(target) {
        let offset = width
        for (let i = indicators.length - 1; i >= 0; i--) {
            const indicator = indicators[i]
            if (!indicator.visible) continue
            offset -= indicator.compactWidth
            if (indicator === target) return offset
            offset -= Spacing.barStatusGap
        }
        return offset
    }

    function slideX(target) {
        let offset = 0
        for (let i = indicators.length - 1; i >= 0; i--) {
            const indicator = indicators[i]
            if (!indicator.visible) continue
            offset -= indicator.revealedWidth
            if (indicator === target) return offset
        }
        return offset
    }

    StatusItem {
        id: bluetoothButton
        x: root.slotX(bluetoothButton)
        transform: Translate { x: root.slideX(bluetoothButton) }
        WidgetAnchor { name: "bluetooth"; target: bluetoothButton }
        statusIcon: Bluetooth.icon
        Accessible.name: Bluetooth.details
        interactive: true
        tint: Bluetooth.enabled ? Colors.text : Colors.textMuted
        onClicked: Widgets.toggle("bluetooth", bluetoothButton.QsWindow.window.screen.name)
    }
    StatusItem {
        id: brightnessButton
        revealPercentage: true
        retainReveal: root.sectionHovered
        x: root.slotX(brightnessButton)
        transform: Translate { x: root.slideX(brightnessButton) }
        visible: Brightness.available
        WidgetAnchor { name: "brightness"; target: brightnessButton }
        statusIcon: "sun"
        label: Brightness.percent + "%"
        Accessible.name: "Screen brightness · " + Brightness.percent + "%"
        interactive: Brightness.available
        onClicked: Widgets.toggle("brightness", brightnessButton.QsWindow.window.screen.name)
        onScrolled: direction => Brightness.adjust(direction)
    }
    StatusItem {
        id: microphone
        revealPercentage: true
        retainReveal: root.sectionHovered
        x: root.slotX(microphone)
        transform: Translate { x: root.slideX(microphone) }
        WidgetAnchor { name: "microphone"; target: microphone }
        statusIcon: Audio.inputMuted ? "microphone-muted" : "microphone"
        label: Audio.inputAvailable ? Audio.inputPercent + "%" : "—"
        Accessible.name: Audio.inputDescription + (Audio.inputMuted ? " · Muted" : "")
        interactive: Audio.inputAvailable
        middleClickEnabled: true
        tint: Audio.inputMuted || !Audio.inputAvailable ? Colors.textMuted : Colors.text
        onClicked: Widgets.toggle("microphone", microphone.QsWindow.window.screen.name)
        onMiddleClicked: Audio.toggleInputMute()
        onScrolled: direction => Audio.adjustInput(direction)
    }
    StatusItem {
        id: volumeButton
        revealPercentage: true
        retainReveal: root.sectionHovered
        x: root.slotX(volumeButton)
        transform: Translate { x: root.slideX(volumeButton) }
        middleClickEnabled: true
        onMiddleClicked: Audio.toggleMute()
        WidgetAnchor { name: "volume"; target: volumeButton }
        statusIcon: !Audio.available || Audio.muted ? "muted" : Audio.percent < 50 ? "volume-low" : "volume"
        label: Audio.available ? Audio.percent + "%" : "—"
        Accessible.name: Audio.description + (Audio.muted ? " · Muted" : "")
        interactive: Audio.available
        tint: Audio.muted ? Colors.textMuted : Colors.text
        onClicked: Widgets.toggle("volume", volumeButton.QsWindow.window.screen.name)
        onScrolled: direction => Audio.adjust(direction)
    }
    StatusItem {
        id: networkButton
        x: root.slotX(networkButton)
        transform: Translate { x: root.slideX(networkButton) }
        WidgetAnchor { name: "network"; target: networkButton }
        statusIcon: Network.icon
        Accessible.name: Network.details
        interactive: true
        tint: Network.connected ? Colors.text : Colors.textMuted
        onClicked: Widgets.toggle("network", networkButton.QsWindow.window.screen.name)
    }
    StatusItem {
        id: batteryButton
        revealPercentage: true
        retainReveal: root.sectionHovered
        x: root.slotX(batteryButton)
        transform: Translate { x: root.slideX(batteryButton) }
        visible: Environment.showBattery
        batteryLevel: Environment.batteryPercent
        statusIcon: Environment.charging ? "charging" : "battery"
        label: Environment.batteryPercent + "%"
        Accessible.name: Environment.charging ? "Charging" : Environment.onBattery ? "On battery" : "Plugged in"
        tint: Environment.onBattery && Environment.batteryPercent <= 20 ? Colors.error : Colors.text
    }
    StatusItem {
        id: bell
        x: root.slotX(bell)
        transform: Translate { x: root.slideX(bell) }
        WidgetAnchor { name: "notifications"; target: bell }
        statusIcon: (Notifications.dnd ? "bell-off" : "bell") + (Notifications.count > 0 ? "-dot" : "")
        Accessible.name: "Notifications · " + Notifications.count + (Notifications.dnd ? " · Do not disturb" : "")
        interactive: true
        middleClickEnabled: true
        tint: Notifications.dnd ? Colors.textMuted : Colors.text
        onClicked: Widgets.toggle("notifications", bell.QsWindow.window.screen.name)
        onMiddleClicked: Notifications.dnd = !Notifications.dnd
    }
}

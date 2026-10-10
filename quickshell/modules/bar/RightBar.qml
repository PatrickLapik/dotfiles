import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.services
import qs.config

RowLayout {
    id: root
    Layout.fillWidth: false
    Layout.alignment: Qt.AlignRight
    spacing: Spacing.sm

    StatusItem {
        id: brightnessButton
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
        WidgetAnchor { name: "network"; target: networkButton }
        statusIcon: Network.icon
        Accessible.name: Network.details
        interactive: true
        tint: Network.connected ? Colors.text : Colors.textMuted
        onClicked: Widgets.toggle("network", networkButton.QsWindow.window.screen.name)
    }
    StatusItem {
        visible: Environment.showBattery
        statusIcon: Environment.charging ? "charging" : "battery"
        label: Environment.batteryPercent + "%"
        Accessible.name: Environment.charging ? "Charging" : Environment.onBattery ? "On battery" : "Plugged in"
        tint: Environment.onBattery && Environment.batteryPercent <= 20 ? Colors.error : Colors.text
    }
    StatusItem {
        id: bell
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

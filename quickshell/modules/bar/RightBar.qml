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
        id: bell
        WidgetAnchor { name: "notifications"; target: bell }
        statusIcon: (Notifications.dnd ? "bell-off" : "bell") + (Notifications.count > 0 ? "-dot" : "")
        tooltip: "Notifications · " + Notifications.count + (Notifications.dnd ? " · Do not disturb" : "")
            + "\nClick for notifications · Middle-click to mute"
        interactive: true
        middleClickEnabled: true
        tint: Notifications.dnd ? Colors.textMuted : Colors.text
        onClicked: Widgets.toggle("notifications", bell.QsWindow.window.screen.name)
        onMiddleClicked: Notifications.dnd = !Notifications.dnd
    }

    StatusItem {
        id: networkButton
        WidgetAnchor { name: "network"; target: networkButton }
        statusIcon: Network.icon
        tooltip: Network.details + "\nClick for network controls"
        interactive: true
        tint: Network.connected ? Colors.text : Colors.textMuted
        onClicked: Widgets.toggle("network", networkButton.QsWindow.window.screen.name)
    }
    StatusItem {
        id: microphone
        WidgetAnchor { name: "microphone"; target: microphone }
        statusIcon: Audio.inputMuted ? "microphone-muted" : "microphone"
        label: Audio.inputAvailable ? Audio.inputPercent + "%" : "—"
        tooltip: Audio.inputDescription + (Audio.inputMuted ? " · Muted" : "") + "\nClick for input controls · Middle-click to mute · Scroll to adjust"
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
        tooltip: Audio.description + (Audio.muted ? " · Muted" : "") + "\nClick for volume controls · Middle-click to mute · Scroll to adjust"
        interactive: Audio.available
        tint: Audio.muted ? Colors.textMuted : Colors.text
        onClicked: Widgets.toggle("volume", volumeButton.QsWindow.window.screen.name)
        onScrolled: direction => Audio.adjust(direction)
    }
    StatusItem {
        visible: Environment.showBattery
        statusIcon: Environment.charging ? "charging" : "battery"
        label: Environment.batteryPercent + "%"
        tooltip: Environment.charging ? "Charging" : Environment.onBattery ? "On battery" : "Plugged in"
        tint: Environment.onBattery && Environment.batteryPercent <= 20 ? Colors.error : Colors.text
    }
}

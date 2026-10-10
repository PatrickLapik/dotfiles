import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.services
import qs.config

RowLayout {
    Layout.fillWidth: false
    Layout.alignment: Qt.AlignLeft
    spacing: Spacing.sm
    PlayingMedia {}

    StatusItem {
        statusIcon: "package"
        label: PackageUpdates.available ? String(PackageUpdates.count) : PackageUpdates.checking ? "…" : "?"
        Accessible.name: PackageUpdates.details
        interactive: true
        middleClickEnabled: true
        tint: !PackageUpdates.available ? Colors.textMuted
            : PackageUpdates.severity === "red" ? Colors.error
            : PackageUpdates.severity === "yellow" ? Colors.tertiary : Colors.text
        onClicked: PackageUpdates.install()
        onMiddleClicked: PackageUpdates.refresh()
    }
}

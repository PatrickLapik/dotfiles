import QtQuick
import Quickshell
import qs.components
import qs.config
import qs.services

Item {
    id: root
    property string icon: ""
    property string kind: "application"
    property color tint: Colors.text
    implicitWidth: Sizing.launcherIconSize
    implicitHeight: Sizing.launcherIconSize
    Image {
        id: image
        anchors.fill: parent
        source: root.icon ? Quickshell.iconPath(root.icon, true) : ""
        sourceSize.width: Sizing.launcherIconSize
        sourceSize.height: Sizing.launcherIconSize
        fillMode: Image.PreserveAspectFit
        visible: status === Image.Ready
    }
    ShellIcon { anchors.fill: parent; visible: image.status !== Image.Ready; kind: root.kind; tint: root.tint }
}

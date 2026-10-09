import QtQuick
import qs.services

QtObject {
    id: root
    required property string name
    required property var openAction
    required property var closeAction
    Component.onCompleted: Widgets.register(name, root, openAction, closeAction)
    Component.onDestruction: Widgets.unregister(name, root)
}

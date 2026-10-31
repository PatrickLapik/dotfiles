import QtQuick
import Quickshell

// Keep the endpoint alive; retain the panel only through preparation and exit.
Scope {
    id: root
    required property string name
    required property Component widgetComponent
    property bool opening: false

    function releaseIfHidden() {
        if (!opening && loader.item && !loader.item.showing)
            loader.active = false
    }
    function open(screenName) {
        opening = true
        loader.active = true
        if (loader.item) loader.item.openWidget(screenName)
        opening = false
        Qt.callLater(releaseIfHidden)
    }
    function close() {
        if (loader.item) loader.item.closeWidget()
        Qt.callLater(releaseIfHidden)
    }
    property WidgetEndpoint endpoint: WidgetEndpoint {
        name: root.name
        openAction: screenName => root.open(screenName)
        closeAction: () => root.close()
    }
    property Loader contentLoader: Loader {
        id: loader
        active: false
        sourceComponent: root.widgetComponent
    }
    property Connections lifecycle: Connections {
        target: loader.item
        function onShowingChanged() { Qt.callLater(root.releaseIfHidden) }
    }
}

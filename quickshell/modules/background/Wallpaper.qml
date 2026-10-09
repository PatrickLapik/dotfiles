import QtQuick
import qs.services
import qs.config

Item {
    id: root
    anchors.fill: parent

    property url source: Wallpapers.source
    readonly property bool transitioning: fade.running
    property int activeIndex: 0
    readonly property var activeImage: activeIndex === 0 ? first : second
    readonly property var pendingImage: activeIndex === 0 ? second : first

    function loadRequested() {
        // Finish the current fade, then load the most recent selection.
        if (!pendingImage || fade.running || source.toString() === activeImage.source.toString())
            return
        pendingImage.opacity = 0
        pendingImage.source = source
        if (pendingImage.status === Image.Ready)
            imageReady(pendingImage)
    }

    function imageReady(image) {
        if (image !== pendingImage || fade.running || image.status !== Image.Ready)
            return
        // The initial image appears immediately; later images fade over it.
        if (activeImage.status !== Image.Ready) {
            commit()
        } else {
            fade.target = image
            fade.start()
        }
    }

    function commit() {
        const previous = activeImage
        pendingImage.opacity = 1
        activeIndex = 1 - activeIndex
        previous.opacity = 0
        previous.source = ""
        loadRequested()
    }

    onSourceChanged: loadRequested()
    Component.onCompleted: loadRequested()

    Image {
        id: first
        anchors.fill: parent
        z: root.activeIndex === 0 ? 0 : 1
        opacity: 1
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        onStatusChanged: root.imageReady(this)
    }

    Image {
        id: second
        anchors.fill: parent
        z: root.activeIndex === 1 ? 0 : 1
        opacity: 0
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        onStatusChanged: root.imageReady(this)
    }

    NumberAnimation {
        id: fade
        property: "opacity"
        from: 0
        to: 1
        duration: Theme.wallpaperTransitionDuration
        easing.type: Easing.InOutCubic
        onFinished: root.commit()
    }
}

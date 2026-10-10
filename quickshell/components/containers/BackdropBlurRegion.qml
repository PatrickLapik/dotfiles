import QtQuick
import Quickshell
import qs.config

// The compositor blurs only the painted surface, never a fullscreen input host.
Region {
    id: root
    required property Item target
    property bool active: Theme.backdropBlurEnabled && target.visible && target.opacity > 0
    property bool animating: false
    // Region tracks item geometry, but render transforms need explicit invalidation.
    onAnimatingChanged: changed()
    property FrameAnimation tracker: FrameAnimation {
        running: root.active && root.animating
        onTriggered: root.changed()
    }
    item: active ? target : null
    radius: target.radius
}

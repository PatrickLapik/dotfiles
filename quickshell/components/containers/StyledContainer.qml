import QtQuick
import QtQuick.Shapes
import qs.config
import qs.services

// Shared surfaces; slantedEdge supports a straight outer edge and angled inner edge.
Item {
    id: root
    property color color: Colors.withAlpha(Colors.surfaceContainer, Theme.panelOpacity)
    Behavior on color {
        ColorAnimation { duration: Animations.enabled ? Animations.feedbackDuration : 0; easing.type: Animations.feedbackEasing }
    }
    property real radius: Theme.radius
    property alias border: normalSurface.border
    property string slantedEdge: "none"
    property real slantWidth: Sizing.barSlantWidth
    readonly property real slant: Math.min(slantWidth, width / 2)
    property real highlightOpacity: Theme.containerHighlightOpacity
    property color highlightColor: Theme.containerHighlightColor
    property color highlightSecondary: Theme.containerHighlightSecondary
    property color highlightTertiary: Theme.containerHighlightTertiary

    // Paint the fill directly on every renderer, with quiet palette highlights.
    // Preserve caller alpha so transparent controls and image masks stay clear.
    function highlighted(accent: color): color {
        return Colors.withAlpha(Qt.tint(root.color,
            Colors.withAlpha(accent, root.highlightOpacity)), root.color.a)
    }
    readonly property color topColor: highlighted(highlightColor)
    readonly property color middleColor: highlighted(highlightSecondary)
    readonly property color bottomColor: highlighted(highlightTertiary)

    Rectangle {
        id: normalSurface
        anchors.fill: parent
        visible: root.slantedEdge === "none"
        color: root.color
        gradient: Gradient {
            GradientStop { position: 0; color: root.topColor }
            GradientStop { position: 0.5; color: root.middleColor }
            GradientStop { position: 1; color: root.bottomColor }
        }
        radius: root.radius
        border.width: Theme.borderNone
        border.color: Colors.border
    }
    Shape {
        anchors.fill: parent
        visible: root.slantedEdge !== "none"
        ShapePath {
            fillColor: root.color
            fillGradient: LinearGradient {
                x1: 0; y1: 0
                x2: 0; y2: root.height
                GradientStop { position: 0; color: root.topColor }
                GradientStop { position: 0.5; color: root.middleColor }
                GradientStop { position: 1; color: root.bottomColor }
            }
            strokeColor: root.border.color
            strokeWidth: root.border.width > 0 ? root.border.width : -1
            joinStyle: ShapePath.MiterJoin
            startX: root.slantedEdge === "left" ? root.slant : 0
            startY: 0
            PathLine { x: root.slantedEdge === "right" ? root.width - root.slant : root.width; y: 0 }
            PathLine { x: root.width; y: root.height }
            PathLine { x: 0; y: root.height }
            PathLine { x: root.slantedEdge === "left" ? root.slant : 0; y: 0 }
        }
    }
    // A cached vector tile adds wear without generating noise on animation frames.
    // Inset past corners/slants so the texture never leaks beyond the surface.
    Image {
        anchors.fill: parent
        anchors.margins: Math.max(root.radius, root.border.width)
        anchors.leftMargin: root.slantedEdge === "left" ? root.slant : Math.max(root.radius, root.border.width)
        anchors.rightMargin: root.slantedEdge === "right" ? root.slant : Math.max(root.radius, root.border.width)
        source: Theme.metalStyle ? "../../assets/iron-grain.svg" : ""
        sourceSize.width: Sizing.surfaceTextureSize
        sourceSize.height: Sizing.surfaceTextureSize
        fillMode: Image.Tile
        opacity: Theme.surfaceTextureOpacity * root.color.a
        visible: opacity > 0 && width > 0 && height > 0
    }

}

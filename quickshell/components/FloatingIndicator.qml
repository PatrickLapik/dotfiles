import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.components.containers
import qs.config
import qs.services

// Passive, reusable OSD. The owner supplies values and calls showFor(screen).
StyledWindow {
    id: root
    property string icon: "volume"
    property string label: ""
    property real value: 0
    property real maximumValue: 100
    property string valueText: Math.round(value) + "%"
    property bool subdued: false
    property int timeout: Theme.indicatorTimeout
    property bool active: false
    readonly property real progress: maximumValue > 0 ? Math.max(0, Math.min(1, value / maximumValue)) : 0

    function showFor(targetScreen) {
        if (targetScreen) screen = targetScreen
        active = true
        hideTimer.restart()
    }

    anchors.bottom: true
    margins.bottom: Spacing.indicatorBottomMargin
    implicitWidth: Sizing.indicatorWidth
    implicitHeight: Sizing.indicatorHeight
    // Keep the native window stable and let every click pass through.
    visible: true
    mask: Region {}
    // Follow the clipped surface through its reveal; never blur an empty region.
    BackgroundEffect.blurRegion: Theme.backdropBlurEnabled && surface.showing && surface.height > 0 ? indicatorBlur : null
    property BackdropBlurRegion indicatorBlur: BackdropBlurRegion {
        target: surface
        animating: surface.transitioning
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Timer {
        id: hideTimer
        interval: root.timeout
        onTriggered: root.active = false
    }

    ExpandingContainer {
        id: surface
        screen: root.screen
        expanded: root.active
        dismissOnOutsideClick: false
        expansionMode: "below"
        expandedWidth: root.width
        expandedHeight: Sizing.indicatorHeight
        collapsedWidth: root.width
        collapsedHeight: 0
        revealOrigin: 0.5
        y: (root.height - height) / 2
        visible: showing

        ExpandingContent {
            surface: surface
            padding: Spacing.panelPadding
            // Keep the final layout centered while the surface unfolds, like StyledPopup.
            y: surface.contentOffsetY + padding
            ColumnLayout {
                anchors.fill: parent
                spacing: Spacing.sm
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Spacing.sm
                    ShellIcon {
                        kind: root.icon
                        tint: root.subdued ? Colors.textMuted : Colors.primary
                        Layout.preferredWidth: Sizing.barIconSize
                        Layout.preferredHeight: Sizing.barIconSize
                    }
                    Text {
                        Layout.fillWidth: true
                        text: root.label
                        elide: Text.ElideRight
                        color: Colors.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                    Text {
                        text: root.valueText
                        color: root.subdued ? Colors.textMuted : Colors.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Theme.emphasisFontWeight
                    }
                }
                StyledContainer {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Sizing.indicatorTrackHeight
                    radius: Theme.radiusSmall
                    color: Colors.surfaceContainerHighest
                    StyledContainer {
                        width: parent.width * root.progress
                        height: parent.height
                        radius: parent.radius
                        color: root.subdued ? Colors.textMuted : Colors.primary
                        Behavior on width {
                            NumberAnimation {
                                duration: Animations.enabled ? Animations.feedbackDuration : 0
                                easing.type: Animations.feedbackEasing
                            }
                        }
                    }
                }
            }
        }
    }
}

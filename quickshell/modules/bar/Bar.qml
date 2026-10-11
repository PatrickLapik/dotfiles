import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.components.containers
import qs.config
import qs.services
import qs.components

Scope {
    Variants {
        model: Quickshell.screens

        StyledWindow {
            id: barWindow
            required property ShellScreen modelData
            property bool revealed: !ShellConfig.barAutoHide
            readonly property bool autoHide: ShellConfig.barAutoHide
            readonly property bool visibilityLocked: BarVisibility.isLocked(screen)
            readonly property bool pointerAtEdge: PointerPosition.nearTop(screen, Sizing.barRevealHeight)
            readonly property bool pointerInBar: PointerPosition.nearTop(screen, ScreenLayout.barBottom)
            readonly property bool popupOpen: Widgets.activeName !== ""
                && Widgets.activeScreenName === screen.name
            onPointerAtEdgeChanged: updateVisibility()
            onPointerInBarChanged: updateVisibility()
            onVisibilityLockedChanged: updateVisibility()
            onAutoHideChanged: updateVisibility()
            Component.onCompleted: updateVisibility()

            function updateVisibility() {
                if (!autoHide || pointerAtEdge || (revealed && pointerInBar) || visibilityLocked) {
                    hideDelay.stop()
                    revealed = true
                } else if (revealed && !hideDelay.running) hideDelay.start()
            }
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            // Reserve a fixed drawing surface; the input mask still follows visible sections.
            // Resizing a Wayland surface every animation frame causes configure stalls.
            implicitHeight: Sizing.barHeight + Spacing.barTopMargin

            BackgroundEffect.blurRegion: Region {
                BackdropBlurRegion { target: leftSection; animating: barMotion.running }
                BackdropBlurRegion { target: centerSection.background; animating: barMotion.running }
                BackdropBlurRegion { target: rightSection; animating: barMotion.running }
            }
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            // Reserve the full bar height (including its top margin) only when pinned.
            exclusionMode: autoHide ? ExclusionMode.Ignore : ExclusionMode.Auto

            // Include the gaps while a popup is open so they can dismiss it.
            // Otherwise only the visible sections and reveal strip receive input.
            mask: Region {
                item: hoverArea
                Region {
                    width: barWindow.popupOpen ? barWindow.width : 0
                    height: barWindow.popupOpen ? Math.max(0, sections.y + sections.height) : 0
                }
                Region {
                    x: sections.x + leftSection.x
                    y: sections.y
                    width: leftSection.width
                    height: sections.visible ? sections.height : 0
                }
                Region {
                    x: sections.x + centerSection.x
                    y: sections.y
                    width: centerSection.width
                    height: sections.visible ? centerSection.height : 0
                }
                Region {
                    x: sections.x + rightSection.x
                    y: sections.y
                    width: rightSection.width
                    height: sections.visible ? sections.height : 0
                }
            }
            Item {
                id: hoverArea
                width: parent.width
                height: Sizing.barRevealHeight
            }
            MouseArea {
                anchors.fill: parent
                enabled: barWindow.popupOpen
                onClicked: Widgets.close(Widgets.activeName)
            }
            Timer {
                id: hideDelay
                interval: Theme.barHideDelay
                onTriggered: {
                    if (barWindow.autoHide && !barWindow.pointerAtEdge && !barWindow.pointerInBar && !barWindow.visibilityLocked)
                        barWindow.revealed = false
                }
            }

            Item {
                id: sections
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Spacing.barLeftMargin
                anchors.rightMargin: Spacing.barRightMargin
                y: barWindow.revealed ? Spacing.barTopMargin : -height
                height: Sizing.barHeight
                visible: y + height > 0
                // Publish the animated edge so overlays follow the bar exactly.
                onYChanged: BarVisibility.setVisibleBottom(barWindow.screen, Math.max(0, y + height))
                Component.onCompleted: BarVisibility.setVisibleBottom(barWindow.screen, Math.max(0, y + height))
                Component.onDestruction: BarVisibility.setVisibleBottom(barWindow.screen, 0)

                Behavior on y {
                    NumberAnimation {
                        id: barMotion
                        duration: !Animations.enabled ? 0 : barWindow.revealed ? Animations.revealDuration : Animations.collapseDuration
                        easing.type: barWindow.revealed ? Animations.revealEasing : Animations.collapseEasing
                    }
                }
                StyledContainer {
                    id: leftSection
                    anchors.left: parent.left
                    height: parent.height
                    width: Math.min(leftContent.implicitWidth + Spacing.panelPadding * 2,
                        Math.max(0, centerSection.x - Spacing.barSectionGap))
                    HoverHandler { id: leftHover }
                    BarVisibilityLock { screen: barWindow.screen; active: leftHover.hovered }
                    LeftBar {
                        id: leftContent
                        anchors.verticalCenter: parent.verticalCenter
                        x: Spacing.panelPadding
                        width: Math.max(0, parent.width - Spacing.panelPadding * 2)
                    }
                }
                StyledButton {
                    id: centerSection
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: Sizing.barHeight
                    implicitWidth: Math.max(Sizing.clockButtonMinWidth, implicitContentWidth + Spacing.panelPadding * 2)
                    text: Time.time
                    font.pixelSize: Theme.fontSizeSmall
                    font.features: { "tnum": 1 }
                    highlightInteractions: false
                    Accessible.name: "Open calendar"
                    WidgetAnchor { name: "clock"; target: centerSection }
                    background: StyledContainer {
                        border.width: centerSection.visualFocus ? Theme.borderSelectedWidth : Theme.borderNone
                        border.color: Colors.primary
                    }
                    onClicked: Widgets.toggle("clock", barWindow.screen.name)
                }
                StyledContainer {
                    id: rightSection
                    anchors.right: parent.right
                    height: parent.height
                    width: Math.min(rightContent.implicitWidth + Spacing.panelPadding * 2,
                        Math.max(0, centerSection.x - Spacing.barSectionGap))
                    HoverHandler { id: rightHover }
                    BarVisibilityLock { screen: barWindow.screen; active: rightHover.hovered }
                    RightBar {
                        id: rightContent
                        anchors.verticalCenter: parent.verticalCenter
                        x: Spacing.panelPadding
                    }
                }
            }
        }
    }
}

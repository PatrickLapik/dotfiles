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
            property bool revealed: false
            readonly property bool visibilityLocked: BarVisibility.isLocked(screen)
            readonly property bool pointerAtEdge: PointerPosition.nearTop(screen, Sizing.barRevealHeight)
            readonly property bool pointerInBar: PointerPosition.nearTop(screen, ScreenLayout.barBottom)
            onPointerAtEdgeChanged: updateVisibility()
            onPointerInBarChanged: updateVisibility()
            onVisibilityLockedChanged: updateVisibility()

            function updateVisibility() {
                if (pointerAtEdge || (revealed && pointerInBar) || visibilityLocked) {
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

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            exclusionMode: ExclusionMode.Ignore

            // Only the screen-edge strip receives input while hidden.
            mask: Region {
                item: hoverArea
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
            Timer {
                id: hideDelay
                interval: Theme.barHideDelay
                onTriggered: {
                    if (!barWindow.pointerInBar && !barWindow.visibilityLocked)
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
                    color: Colors.withAlpha(Colors.panel, Theme.panelOpacity)
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
                    BarToolTip { target: centerSection; hovered: centerSection.hovered; text: Time.date }
                    background: StyledContainer {
                        color: Colors.withAlpha(Colors.panel, Theme.panelOpacity)
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
                    color: Colors.withAlpha(Colors.panel, Theme.panelOpacity)
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

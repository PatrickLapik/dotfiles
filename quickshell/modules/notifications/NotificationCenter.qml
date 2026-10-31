pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.components.containers
import qs.config
import qs.services

LazyWidget {
    name: "notifications"
    widgetComponent: Component {
        Scope {
            FontMetrics { id: notificationFont; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
            readonly property bool showing: popup.surface.showing
            function openWidget(screenName: string) { popup.screen = Widgets.screenFor(screenName); popup.open() }
            function closeWidget() { popup.close() }
            ExpandingPopup {
                id: popup
                anchorName: "notifications"
                animateContentResize: true
                popupWidth: Sizing.notificationCenterWidth
                popupHeight: Sizing.notificationCenterHeight
                onExpandedChanged: Notifications.centerOpen = expanded
                onDismissed: Widgets.closed("notifications")
                ColumnLayout {
                    anchors.fill: parent
                    spacing: Spacing.md
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Spacing.sm
                        Text {
                            Layout.fillWidth: true
                            text: "Notifications"
                            color: Colors.text
                            font.family: Theme.headingFontFamily
                            font.weight: Theme.headingFontWeight
                            font.pixelSize: Theme.fontSizeLarge
                        }
                        Text {
                            visible: Notifications.count > 0
                            text: Notifications.count
                            color: Colors.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.features: { "tnum": 1 }
                        }
                        StyledButton {
                            text: "Clear all"
                            flat: true
                            enabled: Notifications.count > 0 && !Notifications.clearing
                            font.pixelSize: Theme.fontSizeSmall
                            onClicked: Notifications.clearAll()
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 0
                        implicitWidth: Notifications.count > 0 ? Math.max(Sizing.dropdownMinWidth,
                            ...Notifications.history.map(notification => Math.max(
                                notificationFont.advanceWidth(notification.summary || notification.appName),
                                notificationFont.advanceWidth(notification.body.replace(/\s+/g, " ")))
                                + Sizing.notificationCompactIconSize + Sizing.notificationDismissSize + Spacing.sm * 4
                                + Sizing.scrollBarWidth + Spacing.xs)) : emptyState.implicitWidth
                        implicitHeight: presentation.count > 0 ? list.contentHeight : emptyState.implicitHeight
                        ColumnLayout {
                            id: emptyState
                            anchors.centerIn: parent
                            visible: Notifications.count === 0 && presentation.count === 0
                            spacing: Spacing.md
                            ShellIcon {
                                Layout.alignment: Qt.AlignHCenter
                                kind: Notifications.dnd ? "bell-off" : "bell"
                                Layout.preferredWidth: Sizing.notificationEmptyIconSize
                                Layout.preferredHeight: Sizing.notificationEmptyIconSize
                                tint: Colors.textMuted
                            }
                            Text {
                                text: Notifications.dnd ? "Do not disturb is on" : "You're all caught up"
                                color: Colors.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                            }
                        }
                        ListView {
                            id: list
                            boundsBehavior: Flickable.StopAtBounds
                            anchors.fill: parent
                            clip: true
                            spacing: Spacing.sm
                            // ListView's equivalent of the toast stack's move transition.
                            // Animate surviving rows only after an exited card is removed.
                            removeDisplaced: Transition {
                                NumberAnimation {
                                    properties: "y"
                                    duration: Animations.enabled ? Animations.collapseDuration : 0
                                    easing.type: Animations.collapseEasing
                                }
                            }
                            // Retain display data and row geometry until the exit finishes.
                            property var entries: Notifications.history
                            ListModel { id: presentation; dynamicRoles: true }
                            model: presentation
                            function syncEntries() {
                                for (let i = 0; i < presentation.count; ++i) {
                                    const row = presentation.get(i)
                                    if (!entries.some(n => n.id === row.entry.id))
                                        presentation.setProperty(i, "closing", true)
                                }
                                for (let i = 0; i < entries.length; ++i) {
                                    const n = entries[i]
                                    let existing = -1
                                    for (let j = 0; j < presentation.count; ++j)
                                        if (presentation.get(j).entry.id === n.id) { existing = j; break }
                                    const entry = { id: n.id, notification: n, snapshot: {
                                        id: n.id, summary: n.summary, body: n.body, appName: n.appName,
                                        appIcon: n.appIcon, image: n.image, urgency: n.urgency, actions: []
                                    } }
                                    if (existing < 0) presentation.insert(i, { entry: entry, closing: false })
                                    else presentation.setProperty(existing, "entry", entry)
                                }
                            }
                            function finishExit(id) {
                                for (let i = 0; i < presentation.count; ++i)
                                    if (presentation.get(i).entry.id === id && presentation.get(i).closing) {
                                        presentation.remove(i)
                                        return
                                    }
                            }
                            onEntriesChanged: syncEntries()
                            Component.onCompleted: syncEntries()
                            ScrollBar.vertical: StyledScrollBar {}
                            delegate: NotificationCard {
                                id: card
                                required property var entry
                                required property bool closing
                                property real exitProgress: 0
                                width: list.width - Sizing.scrollBarWidth - Spacing.xs
                                notification: entry.notification
                                fallbackDetails: entry.snapshot
                                enabled: !closing
                                transform: Translate { x: card.exitProgress * list.width }
                                onClosingChanged: if (closing) exitAnimation.start()
                                SequentialAnimation {
                                    id: exitAnimation
                                    NumberAnimation {
                                        target: card
                                        property: "exitProgress"
                                        to: 1
                                        duration: Animations.enabled ? Animations.collapseDuration : 0
                                        easing.type: Animations.collapseEasing
                                    }
                                    ScriptAction { script: list.finishExit(card.entry.id) }
                                }
                                onClicked: Notifications.activate(entry.notification, popup.screen.name)
                            }
                        }
                    }
                }
            }
        }
    }
}

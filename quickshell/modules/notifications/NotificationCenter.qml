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
                            enabled: Notifications.count > 0
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
                                // Closing rows on screen slide out bottom-first; rows outside the
                                // viewport are removed at once so large clears finish quickly.
                                const exiting = []
                                const hidden = []
                                for (let i = 0; i < presentation.count; ++i) {
                                    const row = presentation.get(i)
                                    if (row.closing || entries.some(n => n.id === row.entry.id)) continue
                                    const item = itemAtIndex(i)
                                    if (item && item.y + item.height > contentY && item.y < contentY + height)
                                        exiting.push({ index: i, item: item })
                                    else hidden.push(i)
                                }
                                exiting.sort((a, b) => b.item.y - a.item.y)
                                exiting.forEach((exit, rank) => {
                                    exit.item.exitDelay = Animations.enabled ? rank * Animations.notificationClearStagger : 0
                                    presentation.setProperty(exit.index, "closing", true)
                                })
                                for (let i = hidden.length - 1; i >= 0; --i) presentation.remove(hidden[i])
                                for (let i = 0; i < entries.length; ++i) {
                                    const n = entries[i]
                                    let existing = -1
                                    for (let j = 0; j < presentation.count; ++j)
                                        if (presentation.get(j).entry.id === n.id) { existing = j; break }
                                    // Store plain data only; delegates resolve the live object by id.
                                    const entry = { id: n.id, snapshot: {
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
                            // Bulk dismissals change history once per notification; sync once.
                            onEntriesChanged: Qt.callLater(syncEntries)
                            Component.onCompleted: syncEntries()
                            ScrollBar.vertical: StyledScrollBar {}
                            delegate: NotificationCard {
                                id: card
                                required property var entry
                                required property bool closing
                                property real exitProgress: 0
                                property int exitDelay: 0
                                width: list.width - Sizing.scrollBarWidth - Spacing.xs
                                notification: closing ? null : Notifications.find(entry.id)
                                fallbackDetails: entry.snapshot
                                // Cards sit on the center's glass; don't stack another panel tint.
                                color: Colors.glassFill
                                enabled: !closing
                                transform: Translate { x: card.exitProgress * list.width }
                                onClosingChanged: if (closing) exitAnimation.start()
                                Component.onCompleted: if (closing) exitAnimation.start()
                                SequentialAnimation {
                                    id: exitAnimation
                                    PauseAnimation { duration: card.exitDelay }
                                    NumberAnimation {
                                        target: card
                                        property: "exitProgress"
                                        to: 1
                                        duration: Animations.enabled ? Animations.collapseDuration : 0
                                        easing.type: Animations.collapseEasing
                                    }
                                    ScriptAction { script: list.finishExit(card.entry.id) }
                                }
                                onClicked: Notifications.activate(card.notification, popup.screen.name)
                            }
                        }
                    }
                }
            }
        }
    }
}

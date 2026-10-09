pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.components.containers
import qs.config
import qs.services

Scope {
    WidgetEndpoint {
        name: "clock"
        openAction: screenName => { popup.screen = Widgets.screenFor(screenName); popup.open() }
        closeAction: () => popup.close()
    }
    ExpandingPopup {
        id: popup
        anchorName: "clock"
        popupWidth: Sizing.clockMenuWidth
        popupHeight: Brightness.available ? Sizing.clockMenuHeight : Sizing.clockMenuCompactHeight
        property date monthDate: new Date()
        property date selectedDate: new Date()
        onExpandedChanged: {
            if (expanded) {
                monthDate = new Date()
                selectedDate = new Date()
            }
        }
        onDismissed: Widgets.closed("clock")
        ColumnLayout {
            anchors.fill: parent
            spacing: Spacing.sm
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Spacing.xs
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Time.time
                    color: Colors.text
                    font.family: Theme.fontFamily
                    font.weight: Theme.controlFontWeight
                    font.pixelSize: Theme.clockExpandedFontSize
                    font.features: { "tnum": 1 }
                }
                Text {
                    Layout.fillWidth: true
                    text: Time.date
                    horizontalAlignment: Text.AlignHCenter
                    color: Colors.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    elide: Text.ElideRight
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Spacing.xs
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Spacing.xs
                    Text {
                        Layout.fillWidth: true
                        text: Qt.formatDateTime(popup.monthDate, "MMMM yyyy")
                        color: Colors.text
                        font.family: Theme.fontFamily
                        font.weight: Theme.headingFontWeight
                        font.pixelSize: Theme.fontSize
                    }
                    StyledButton {
                        text: "Today"
                        flat: true
                        font.pixelSize: Theme.fontSizeSmall
                        onClicked: { popup.monthDate = new Date(); popup.selectedDate = new Date() }
                    }
                    StyledIconButton {
                        iconName: "chevron-left"
                        Accessible.name: "Previous month"
                        onClicked: popup.monthDate = new Date(popup.monthDate.getFullYear(), popup.monthDate.getMonth() - 1, 1)
                    }
                    StyledIconButton {
                        iconName: "chevron-right"
                        Accessible.name: "Next month"
                        onClicked: popup.monthDate = new Date(popup.monthDate.getFullYear(), popup.monthDate.getMonth() + 1, 1)
                    }
                }
                DayOfWeekRow {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Sizing.calendarWeekdayHeight
                    locale: month.locale
                    delegate: Text {
                        required property string shortName
                        text: shortName
                        color: Colors.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                MonthGrid {
                    id: month
                    Layout.fillWidth: true
                    Layout.preferredHeight: Sizing.calendarHeight
                    month: popup.monthDate.getMonth()
                    year: popup.monthDate.getFullYear()
                    locale: Qt.locale()
                    delegate: Item {
                        id: dayCell
                        required property var model
                        StyledButton {
                            id: dayButton
                            anchors.centerIn: parent
                            width: Sizing.calendarDaySize
                            height: Sizing.calendarDaySize
                            padding: 0
                            text: dayCell.model.day
                            checked: dayCell.model.date.toDateString() === popup.selectedDate.toDateString()
                            Accessible.name: Qt.formatDateTime(dayCell.model.date, "dddd, d MMMM yyyy")
                            onClicked: popup.selectedDate = dayCell.model.date
                            background: StyledContainer {
                                radius: Theme.radiusSmall
                                color: dayButton.checked ? Colors.primaryContainer
                                    : dayButton.hovered || dayCell.model.today ? Colors.surfaceContainerHigh : "transparent"
                                border.width: dayButton.visualFocus ? Theme.borderSelectedWidth : Theme.borderNone
                                border.color: Colors.primary
                            }
                            contentItem: Text {
                                text: dayButton.text
                                font.family: Theme.fontFamily
                                font.weight: Theme.controlFontWeight
                                font.pixelSize: Theme.fontSizeSmall
                                font.features: { "tnum": 1 }
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: dayButton.checked ? Colors.onPrimaryContainer
                                    : dayCell.model.today ? Colors.primary : Colors.text
                                opacity: dayCell.model.month === month.month ? 1 : Theme.inactiveCalendarOpacity
                            }
                        }
                    }
                }
            }
            Item { Layout.fillHeight: true }
            Rectangle { Layout.fillWidth: true; implicitHeight: Theme.borderWidth; color: Colors.border }
            ColumnLayout {
                Layout.fillWidth: true
                visible: Brightness.available
                spacing: Spacing.xs
                RowLayout {
                    Layout.fillWidth: true
                    ShellIcon { kind: "sun"; tint: Colors.textMuted }
                    Text {
                        Layout.fillWidth: true
                        text: "Brightness"
                        color: Colors.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                    Text {
                        text: Math.round(brightness.value) + "%"
                        color: Colors.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.features: { "tnum": 1 }
                    }
                }
                StyledSlider {
                    id: brightness
                    Layout.fillWidth: true
                    from: 1; to: 100
                    value: Brightness.percent
                    Accessible.name: "Screen brightness"
                    onMoved: Brightness.setPercent(value)
                }
                Text {
                    Layout.fillWidth: true
                    visible: Brightness.error !== ""
                    text: "Brightness could not be changed"
                    wrapMode: Text.Wrap
                    color: Colors.error
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
            StyledButton {
                Layout.fillWidth: true
                text: "Wallpapers"
                flat: true
                onClicked: Widgets.open("wallpapers", popup.screen.name)
                contentItem: RowLayout {
                    spacing: Spacing.sm
                    ShellIcon { kind: "wallpaper"; tint: Colors.textMuted }
                    Text {
                        Layout.fillWidth: true
                        text: "Wallpapers"
                        color: Colors.text
                        font.family: Theme.fontFamily
                        font.weight: Theme.controlFontWeight
                        font.pixelSize: Theme.fontSizeSmall
                    }
                    ShellIcon { kind: "chevron-right"; tint: Colors.textMuted }
                }
            }
        }
    }
}

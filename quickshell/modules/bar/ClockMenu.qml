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
        popupHeight: Sizing.clockMenuHeight
        // Both calendar controls share a Monday-first locale.
        readonly property var calendarLocale: Qt.locale("en_GB")
        property date monthDate: new Date()
        property date selectedDate: new Date()
        function goToToday() {
            monthDate = Time.currentDate
            selectedDate = Time.currentDate
        }
        function changeMonth(offset: int) {
            monthDate = new Date(monthDate.getFullYear(), monthDate.getMonth() + offset, 1)
        }
        onExpandedChanged: if (expanded) goToToday()
        onDismissed: Widgets.closed("clock")
        ColumnLayout {
            anchors.fill: parent
            spacing: Spacing.sm
            Text {
                Layout.fillWidth: true
                text: Qt.formatDateTime(Time.currentDate, "dddd, d MMMM")
                color: Colors.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                elide: Text.ElideRight
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: Spacing.xs
                Text {
                    Layout.fillWidth: true
                    text: Qt.formatDateTime(popup.monthDate, "MMMM yyyy")
                    color: Colors.text
                    font.family: Theme.headingFontFamily
                    font.weight: Theme.headingFontWeight
                    font.pixelSize: Theme.fontSizeLarge
                }
                StyledButton {
                    text: "Today"
                    flat: true
                    padding: Spacing.xs
                    font.pixelSize: Theme.fontSizeSmall
                    onClicked: popup.goToToday()
                }
                StyledIconButton {
                    iconName: "chevron-left"
                    Accessible.name: "Previous month"
                    onClicked: popup.changeMonth(-1)
                }
                StyledIconButton {
                    iconName: "chevron-right"
                    Accessible.name: "Next month"
                    onClicked: popup.changeMonth(1)
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Spacing.xs
                DayOfWeekRow {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Sizing.calendarWeekdayHeight
                    padding: 0
                    spacing: Spacing.xs
                    locale: popup.calendarLocale
                    delegate: Text {
                        required property string shortName
                        required property int index
                        text: shortName
                        color: index >= 5 ? Colors.secondary : Colors.textMuted
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
                    padding: 0
                    spacing: Spacing.xs
                    month: popup.monthDate.getMonth()
                    year: popup.monthDate.getFullYear()
                    locale: popup.calendarLocale
                    delegate: Item {
                        id: dayCell
                        required property var model
                        readonly property bool weekend: model.date.getDay() === 0 || model.date.getDay() === 6
                        StyledButton {
                            id: dayButton
                            anchors.centerIn: parent
                            width: Sizing.calendarDaySize
                            height: Sizing.calendarDaySize
                            padding: 0
                            highlightInteractions: false
                            text: dayCell.model.day
                            checked: dayCell.model.date.toDateString() === popup.selectedDate.toDateString()
                            Accessible.name: Qt.formatDateTime(dayCell.model.date, "dddd, d MMMM yyyy")
                                + (dayCell.model.today ? ", today" : "")
                            onClicked: {
                                popup.selectedDate = dayCell.model.date
                                if (dayCell.model.month !== month.month)
                                    popup.monthDate = new Date(dayCell.model.date.getFullYear(), dayCell.model.month, 1)
                            }
                            background: StyledContainer {
                                radius: Theme.radiusSmall
                                color: dayButton.checked ? Colors.primaryContainer
                                    : dayButton.hovered ? Colors.surfaceContainerHigh : "transparent"
                                border.width: dayButton.visualFocus ? Theme.borderSelectedWidth
                                    : dayCell.model.today ? Theme.borderWidth : Theme.borderNone
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
                                    : dayCell.model.today ? Colors.primary
                                    : dayCell.weekend ? Colors.secondary : Colors.text
                                opacity: dayCell.model.month === month.month ? 1 : Theme.inactiveCalendarOpacity
                            }
                        }
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: Spacing.sm
                Text {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    text: popup.selectedDate.toDateString() === Time.currentDate.toDateString()
                        ? "Today" : Qt.formatDateTime(popup.selectedDate, "ddd, d MMM yyyy")
                    color: Colors.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    elide: Text.ElideRight
                }
                StyledButton {
                    text: "Wallpapers"
                    flat: true
                    padding: Spacing.xs
                    onClicked: Widgets.open("wallpapers", popup.screen.name)
                    contentItem: RowLayout {
                        spacing: Spacing.xs
                        ShellIcon { kind: "wallpaper"; tint: Colors.textMuted }
                        Text {
                            text: "Wallpapers"
                            color: Colors.text
                            font.family: Theme.fontFamily
                            font.weight: Theme.controlFontWeight
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                }
            }
        }
    }
}

pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components
import qs.components.containers
import qs.config
import qs.services
import qs.modules.wallpapers

ExpandingContainer {
    id: root
    property date monthDate: new Date()
    property date selectedDate: new Date()
    collapsedWidth: compactMeasure.implicitWidth + Spacing.panelPadding * 2
    expandedWidth: Math.min(Sizing.clockMenuWidth,
        screen ? Math.max(0, screen.width - Spacing.barLeftMargin - Spacing.barRightMargin) : Sizing.clockMenuWidth)
    expandedHeight: Sizing.clockMenuHeight
    color: Colors.withAlpha(Colors.panel, Theme.panelOpacity)
    activeFocusOnTab: true
    Keys.onEscapePressed: expanded = false
    Keys.onReturnPressed: expanded = !expanded
    Keys.onSpacePressed: expanded = !expanded
    onExpandedChanged: {
        if (expanded) {
            monthDate = new Date()
            selectedDate = new Date()
            forceActiveFocus()
        }
    }
    Text {
        id: compactMeasure
        visible: false
        text: Time.time
        font.weight: Theme.fontWeight; font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
    }
    Text {
        id: clockText
        anchors.horizontalCenter: parent.horizontalCenter
        y: (Sizing.barHeight - height) / 2 * (1 - root.progress) + Spacing.lg * root.progress
        text: Time.time
        color: Colors.text
        font.weight: Theme.fontWeight; font.family: Theme.fontFamily
        // Scale a fixed glyph layout instead of rebuilding text at every font size.
        font.pixelSize: Theme.clockExpandedFontSize
        scale: Theme.fontSizeSmall / Theme.clockExpandedFontSize
            + (1 - Theme.fontSizeSmall / Theme.clockExpandedFontSize) * root.progress
    }
    MouseArea {
        width: parent.width
        height: Sizing.barHeight + (Theme.clockExpandedFontSize + Spacing.lg * 2 - Sizing.barHeight) * root.progress
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = !root.expanded
    }
    ExpandingContent {
        surface: root
        topInset: Spacing.lg + clockText.height + Spacing.md
        RowLayout {
            anchors.fill: parent
            spacing: Spacing.md
            StyledContainer {
                Layout.preferredWidth: Sizing.clockCalendarWidth
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Colors.surfaceContainerLow
                radius: Theme.radiusLarge
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Spacing.lg
                    spacing: Spacing.md
                    Text {
                        text: "Calendar"
                        color: Colors.textMuted
                        font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        StyledButton {
                            padding: Spacing.sm
                            id: previousMonth
                            text: "‹"
                            onClicked: root.monthDate = new Date(root.monthDate.getFullYear(), root.monthDate.getMonth() - 1, 1)
                            background: StyledContainer { color: previousMonth.hovered ? Colors.surfaceContainerHighest : Colors.surfaceContainerHigh; radius: Theme.radiusSmall }
                            contentItem: Text { text: previousMonth.text; color: Colors.text; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeLarge; horizontalAlignment: Text.AlignHCenter }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: Qt.formatDateTime(root.monthDate, "MMMM yyyy")
                            horizontalAlignment: Text.AlignHCenter
                            color: Colors.text
                            font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }
                        StyledButton {
                            padding: Spacing.sm
                            id: todayButton
                            text: "Today"
                            onClicked: { root.monthDate = new Date(); root.selectedDate = new Date() }
                            background: StyledContainer { color: todayButton.hovered ? Colors.surfaceContainerHighest : Colors.surfaceContainerHigh; radius: Theme.radiusSmall }
                            contentItem: Text { text: todayButton.text; color: Colors.text; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                        }
                        StyledButton {
                            padding: Spacing.sm
                            id: nextMonth
                            text: "›"
                            onClicked: root.monthDate = new Date(root.monthDate.getFullYear(), root.monthDate.getMonth() + 1, 1)
                            background: StyledContainer { color: nextMonth.hovered ? Colors.surfaceContainerHighest : Colors.surfaceContainerHigh; radius: Theme.radiusSmall }
                            contentItem: Text { text: nextMonth.text; color: Colors.text; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeLarge; horizontalAlignment: Text.AlignHCenter }
                        }
                    }
                    DayOfWeekRow {
                        Layout.fillWidth: true
                        locale: month.locale
                        delegate: Text {
                            required property string shortName
                            text: shortName
                            color: Colors.textMuted
                            font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                    MonthGrid {
                        id: month
                        Layout.fillWidth: true
                        Layout.preferredHeight: Sizing.calendarHeight
                        month: root.monthDate.getMonth()
                        year: root.monthDate.getFullYear()
                        locale: Qt.locale()
                        onClicked: date => root.selectedDate = date
                        delegate: StyledContainer {
                            required property var model
                            radius: Theme.radiusSmall
                            border.width: model.today ? Theme.borderWidth : Theme.borderNone
                            border.color: Colors.primary
                            color: model.date.toDateString() === root.selectedDate.toDateString() ? Colors.primaryContainer : "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: parent.model.day
                                color: parent.model.date.toDateString() === root.selectedDate.toDateString() ? Colors.onPrimaryContainer : parent.model.today ? Colors.primary : parent.model.month === month.month ? Colors.text : Colors.textMuted
                                font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                            }
                        }
                    }
                    StyledContainer {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Sizing.clockPlaceholderHeight
                        color: Colors.surfaceContainerHigh
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: Spacing.md
                            spacing: Spacing.xs
                            Text { text: "Agenda · " + Qt.formatDateTime(root.selectedDate, "ddd, d MMM"); color: Colors.text; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
                            Text { text: "Your upcoming events will appear here"; color: Colors.textMuted; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                        }
                    }
                    Item { Layout.fillHeight: true }
                }
            }
            StyledContainer {
                Layout.preferredWidth: Sizing.clockActionsWidth
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Colors.surfaceContainerLow
                radius: Theme.radiusLarge
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Spacing.lg
                    spacing: Spacing.md
                    Text { text: "Appearance"; color: Colors.text; Layout.maximumHeight: Theme.headingLineHeight; font.weight: Theme.headingFontWeight; font.family: Theme.headingFontFamily; font.letterSpacing: Theme.headingLetterSpacing; font.pixelSize: Theme.fontSizeLarge }
                    Text {
                        Layout.fillWidth: true
                        text: "Choose a wallpaper and refresh your theme."
                        wrapMode: Text.Wrap
                        color: Colors.textMuted
                        font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                    WallpaperPicker {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Sizing.clockActionHeight
                        color: Colors.primaryContainer
                        onPickerOpened: root.expanded = false
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: Brightness.available
                        spacing: Spacing.xs
                        Text { text: "Brightness · " + Math.round(brightnessSlider.value) + "%"; color: Colors.text; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
                        Slider {
                            id: brightnessSlider
                            Layout.fillWidth: true
                            from: 1; to: 100
                            value: Brightness.percent
                            onMoved: Brightness.setPercent(value)
                            background: StyledContainer {
                                x: brightnessSlider.leftPadding
                                y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                                width: brightnessSlider.availableWidth
                                height: Spacing.xs
                                radius: Theme.radiusSmall
                                color: Colors.surfaceContainerHighest
                                StyledContainer { width: parent.width * brightnessSlider.visualPosition; height: parent.height; radius: Theme.radiusSmall; color: Colors.primary }
                            }
                            handle: StyledContainer {
                                x: brightnessSlider.leftPadding + brightnessSlider.visualPosition * (brightnessSlider.availableWidth - width)
                                y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                                implicitWidth: Sizing.brightnessHandleSize
                                implicitHeight: Sizing.brightnessHandleSize
                                radius: Theme.radiusLarge
                                color: Colors.primary
                            }
                        }
                        Text { visible: Brightness.error !== ""; text: "Brightness could not be changed"; color: Colors.error; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                    }
                    Item { Layout.fillHeight: true }
                    Text {
                        Layout.fillWidth: true
                        text: Time.date
                        wrapMode: Text.Wrap
                        color: Colors.textMuted
                        font.weight: Theme.fontWeight; font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
            }
        }
    }
}

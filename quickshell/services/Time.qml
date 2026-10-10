pragma Singleton

import Quickshell

Singleton {
    id: root
    readonly property date currentDate: clock.date
    readonly property string time: {
        Qt.formatDateTime(clock.date, "hh:mm");
    }

    readonly property string date: Qt.formatDateTime(clock.date, "dddd, d MMMM yyyy")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}

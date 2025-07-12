pragma Singleton

import Quickshell

Singleton {
    id: root
    readonly property string time: {
        Qt.formatDateTime(clock.date, "hh:mm:ss yyyy");
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}

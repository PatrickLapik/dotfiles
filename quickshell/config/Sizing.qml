pragma Singleton
import Quickshell

Singleton {
    readonly property int lockFormWidth: ShellConfig.scaled(320)
    readonly property int lockInputHeight: ShellConfig.scaled(48)
    readonly property int lockIconSize: ShellConfig.scaled(64)
    readonly property int lockJokeWidth: ShellConfig.scaled(540)
    readonly property int lockCompactHeight: ShellConfig.scaled(620)
    readonly property int lockBlurRadius: 64

    readonly property int mediaPanelWidth: ShellConfig.scaled(400)
    readonly property int mediaPanelHeight: ShellConfig.scaled(260)
    readonly property int scrollBarWidth: ShellConfig.scaled(6)
    readonly property int scrollBarThumbWidth: ShellConfig.scaled(2)
    readonly property int clipboardWidth: ShellConfig.scaled(500)
    readonly property int clipboardHeight: ShellConfig.scaled(420)
    readonly property int clipboardRowHeight: ShellConfig.scaled(44)
    readonly property int surfaceTextureSize: 256
    readonly property real containerGlassRimWidth: 1.4 * ShellConfig.effectiveUiScale
    readonly property int containerGlassGlowWidth: ShellConfig.scaled(6)
    readonly property int dropdownMinWidth: ShellConfig.scaled(160)
    readonly property int dropdownHeight: ShellConfig.scaled(36)
    readonly property int dropdownRowHeight: ShellConfig.scaled(44)
    readonly property int dropdownMaxHeight: ShellConfig.scaled(220)
    readonly property int dropdownIndicatorSize: ShellConfig.scaled(16)
    readonly property int brightnessPanelWidth: ShellConfig.scaled(360)
    readonly property int brightnessPanelHeight: ShellConfig.scaled(160)
    readonly property int volumePanelWidth: ShellConfig.scaled(360)
    readonly property int volumePanelHeight: ShellConfig.scaled(160)
    readonly property int bluetoothPanelWidth: networkPanelWidth
    readonly property int bluetoothPanelHeight: networkPanelHeight
    readonly property int bluetoothRowHeight: networkRowHeight
    readonly property int networkPanelWidth: ShellConfig.scaled(400)
    readonly property int networkPanelHeight: ShellConfig.scaled(520)
    readonly property int networkRowHeight: ShellConfig.scaled(58)
    readonly property int audioDefaultButtonWidth: ShellConfig.scaled(112)
    readonly property int volumeHandleSize: ShellConfig.scaled(18)
    readonly property int notificationCenterWidth: ShellConfig.scaled(440)
    readonly property int notificationCenterHeight: ShellConfig.scaled(560)
    readonly property int notificationCardMinHeight: ShellConfig.scaled(80)
    readonly property int notificationToastWidth: ShellConfig.scaled(360)
    readonly property int notificationIconSize: ShellConfig.scaled(36)
    readonly property int notificationCompactIconSize: ShellConfig.scaled(28)
    readonly property int notificationDismissSize: ShellConfig.scaled(24)
    readonly property int notificationProgressHeight: ShellConfig.scaled(3)
    readonly property int audioInputMeterHeight: notificationProgressHeight
    readonly property int notificationEmptyIconSize: ShellConfig.scaled(32)
    readonly property int notificationMaxToasts: 3
    readonly property int notificationHistoryLimit: 100
    readonly property int barSlantWidth: ShellConfig.scaled(20)
    readonly property int iconBadgeSize: ShellConfig.scaled(4)
    readonly property int barIconSize: ShellConfig.scaled(20)
    readonly property int barHeight: ShellConfig.scaled(46)
    readonly property int clockMenuWidth: ShellConfig.scaled(460)
    readonly property int clockMenuHeight: ShellConfig.scaled(420)
    readonly property int calendarHeight: ShellConfig.scaled(240)
    readonly property int calendarDaySize: ShellConfig.scaled(32)
    readonly property int calendarWeekdayHeight: ShellConfig.scaled(20)
    readonly property int clockButtonMinWidth: ShellConfig.scaled(90)
    readonly property int barRevealHeight: ShellConfig.scaled(2)
    readonly property int mediaTextMaxWidth: ShellConfig.scaled(280)
    readonly property int widgetHeight: ShellConfig.scaled(34)
    readonly property int launcherWidth: ShellConfig.scaled(600)
    readonly property int launcherHeight: ShellConfig.scaled(560)
    readonly property int launcherRowHeight: ShellConfig.scaled(64)
    readonly property int launcherIconSize: ShellConfig.scaled(32)
    readonly property int powerMenuWidth: ShellConfig.scaled(360)
    readonly property int powerMenuHeight: ShellConfig.scaled(360)
    readonly property int powerMenuRowHeight: ShellConfig.scaled(44)
    readonly property int popupWidth: ShellConfig.scaled(640)
    readonly property int popupHeight: ShellConfig.scaled(540)
    readonly property int popupMinWidth: ShellConfig.scaled(0)
    readonly property int popupMinHeight: ShellConfig.scaled(0)
    readonly property int wallpaperColumns: 3
    readonly property int wallpaperPickerWidth: ShellConfig.scaled(960)
    readonly property int wallpaperPickerHeight: ShellConfig.scaled(660)
    readonly property int wallpaperMinCellWidth: ShellConfig.scaled(220)
    readonly property int wallpaperCaptionHeight: ShellConfig.scaled(24)
    readonly property int wallpaperSchemeWidth: ShellConfig.scaled(220)
    readonly property int wallpaperThumbnailWidth: 640
    readonly property int wallpaperThumbnailHeight: 360
    readonly property real wallpaperPreviewAspectRatio: wallpaperThumbnailWidth / wallpaperThumbnailHeight
    // Numeric dimensions are unscaled logical pixels; percentages use the host's
    // available monitor space. "content" fits that axis within its bounds.
    // Omitted width/height follow ShellConfig.popupHugContents and legacy defaults.
    readonly property var popupLimits: ({
        bluetooth: { width: "content", minWidth: 400, maxWidth: 460, height: "content", maxHeight: "70%" },
        network: { width: "content", minWidth: 400, maxWidth: 460, height: "content", maxHeight: "70%" },
        brightness: { width: "content", minWidth: 360, maxWidth: 460, height: "content", maxHeight: 160 },
        volume: { width: "content", minWidth: 400, maxWidth: 460, height: "content", maxHeight: 160 },
        microphone: { width: "content", minWidth: 400, maxWidth: 460, height: "content", maxHeight: 160 },
        media: { width: "30%", minWidth: 400, maxWidth: 460, height: "content", maxHeight: 260 },
        clock: { width: "content", minWidth: 400, maxWidth: 460, height: "content", maxHeight: 420 },
        notifications: { width: "30%", minWidth: 400, maxWidth: 500, height: "content", maxHeight: "50%" },
        clipboard: { width: 500, minWidth: 460, maxWidth: 500, height: 420, maxHeight: "70%" },
        launcher: { width: "40%", minWidth: 480, maxWidth: 900, height: 640, maxHeight: "80%" },
        power: { width: 360, maxWidth: 360, height: "content", maxHeight: "80%" },
        wallpapers: { width: "40%", minWidth: 480, maxWidth: 900, height: 660, maxHeight: "80%" }
    })
}

pragma Singleton
import Quickshell

Singleton {
    readonly property int lockEdgeInset: ShellConfig.scaled(64)
    readonly property int scrollBarPadding: ShellConfig.scaled(1)
    readonly property int xs: ShellConfig.scaled(4)
    readonly property int sm: ShellConfig.scaled(10)
    readonly property int md: ShellConfig.scaled(14)
    readonly property int lg: ShellConfig.scaled(18)
    readonly property int xl: ShellConfig.scaled(28)

    readonly property int barSectionGap: xl
    readonly property int barMargin: md
    readonly property int barLeftMargin: barMargin
    readonly property int barRightMargin: barMargin
    readonly property int screenTopMargin: sm
    readonly property int barTopMargin: screenTopMargin
    readonly property int barPopupGap: sm
    readonly property int notificationTopMargin: screenTopMargin
    readonly property int notificationBarGap: barPopupGap
    readonly property int panelPadding: lg
    readonly property int widgetSpacing: sm
}

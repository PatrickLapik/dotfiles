pragma Singleton
import Quickshell

Singleton {
    readonly property int scrollBarPadding: 1
    readonly property int xs: 4
    readonly property int sm: 10
    readonly property int md: 14
    readonly property int lg: 18
    readonly property int xl: 28

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

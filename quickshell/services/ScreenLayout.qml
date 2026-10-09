pragma Singleton
import Quickshell
import qs.config

// Screen coordinates shared by top-aligned surfaces. Native windows stay fixed.
Singleton {
    readonly property real topMargin: Spacing.screenTopMargin
    readonly property real barBottom: Spacing.barTopMargin + Sizing.barHeight
    readonly property real barPopupTop: barBottom + Spacing.barPopupGap

    // Blend the edge inset into the gap below the bar as it reveals.
    function topOffset(screen: ShellScreen, edgeMargin: real, barGap: real): real {
        const bottom = BarVisibility.visibleBottom(screen)
        const progress = barBottom > 0 ? Math.max(0, Math.min(1, bottom / barBottom)) : 0
        return bottom + edgeMargin + (barGap - edgeMargin) * progress
    }
}

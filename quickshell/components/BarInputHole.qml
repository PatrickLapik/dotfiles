import Quickshell
import qs.config
import qs.services

// Subtract the bar from overlay input masks, including while it is animating.
Region {
    property ShellScreen screen
    readonly property bool pointerInside: PointerPosition.nearTop(screen, height)
    intersection: Intersection.Subtract
    height: Math.max(ScreenLayout.barBottom,
        BarVisibility.visibleBottom(screen))
}

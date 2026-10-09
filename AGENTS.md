# UI conventions

Use `components/StyledSlider.qml` for sliders; it shares the volume panel's track, fill, handle, and pointer behavior. Keep values and actions in the owning widget.

Use `components/StyledButton.qml` (`import qs.components`) for buttons. It provides the shared typography, spacing, StyledContainer background, focus indication, and pointer cursor while preserving Qt button keyboard, checkable, and accessibility behavior. Override its surface/content only when needed for a specific appearance; keep cursor handling in the shared component.

Use values from `quickshell/config/Theme.qml`, `Spacing.qml`, `Sizing.qml`, and `Animations.qml` for padding, spacing, radii, typography, dimensions, and interaction animations. Use the reveal/expand/collapse presets in `Animations.qml`; animate transforms and opacity over stable layouts rather than resizing windows or reflowing content every frame. Add shared tokens there when needed.

Notification toasts slide horizontally from/to the screen edge at full opacity. Keep their window and delegate layout stable during the transition, retain display data after the native notification closes, and remove the visual delegate only when its exit animation finishes. Shared popups and tooltips use `Animations.qml` presets for both entry and exit; interaction feedback uses its feedback preset. Respect `Animations.enabled` for every interaction transition.

Every new or updated Quickshell visual container must use `quickshell/components/containers/StyledContainer.qml` (`import qs.components.containers`). This includes bars, tooltips, popup/dialog surfaces, cards, and widget/control backgrounds. Override its color, radius, or border with shared tokens when a surface needs a different appearance; keep the common defaults in `StyledContainer`.

Keep window behavior in `StyledWindow`/`PanelWindow`/`PopupWindow` and put a `StyledContainer` inside for the visible surface. Plain `Item`/layout elements remain appropriate for layout only, and `Rectangle` may be used for drawing primitives such as dividers, rather than containers.

# Expanding surfaces and animations

Use `components/containers/ExpandingContainer.qml` for animated button-to-panel expansion. It extends `StyledContainer`, shares the `Animations.qml` open/close presets, exposes `expanded`, `progress`, `showing`, and collapsed/expanded dimensions, and holds a per-screen `BarVisibilityLock` through closing. Use `ExpandingContent.qml` inside it for fixed-size content that slides/fades without per-frame layout changes. Keep headers at a fixed font size and animate scale when enlarging text.

Keep the containing window at a fixed size and animate only the visible surface. Its input region must follow the animated surface; hidden areas should pass clicks through. Keep the surface visible until `showing` becomes false, and leave expanded content disabled while closing. Configure timings and easing in `config/Animations.qml` (`enabled`, `revealDuration/revealEasing`, `expandDuration/expandEasing`, `collapseDuration/collapseEasing`); keep layout distances in `Spacing.qml` and dimensions in `Sizing.qml`. Never introduce local animation timings or resize a native window every frame.

# Widget launching

`ExpandingContainer` supplies click-outside dismissal through a transparent, fixed-size input window with a hole following the animated surface. Set `dismissOnOutsideClick: false` only when the containing window already provides outside-click dismissal. The dismiss layer is active only while expanded and releases input immediately when closing starts.

Register shell widgets with `quickshell/components/WidgetEndpoint.qml` and the shared `services/Widgets.qml` registry. Instantiate their module in `shell.qml`. Use `Widgets.open/toggle/close(name, screenName)` from QML and `scripts/widget.sh <name> [open|toggle|close]` from keybindings; `scripts/widget.sh list` lists available widgets. The helper selects the focused monitor and calls the single `widgets` IPC endpoint in `WidgetHost.qml`. Avoid separate IPC handlers or launch scripts for new widgets.

Use `Widgets.screenFor(screenName)` when opening and call `Widgets.closed(name)` when dismissed. The registry closes other registered widgets before opening one. Use `CenteredPopup` for centered dialogs. Bar-related popups should keep its default `keepBarVisible: true`; other expanded surfaces and interactive overlays should use `BarVisibilityLock` for their monitor while open or hovered so the bar cannot hide during interaction.

For expansion from an existing container, register the source with `WidgetAnchor { name: "widget-name"; target: sourceContainer }`. Resolve it per monitor with `Widgets.anchorFor(name, screen.name)` and call `ExpandingContainer.expandFrom(source)`. This captures the source's actual position and dimensions; the surface grows from and collapses back to that rectangle. Keep source and host window coordinates aligned, or supply `sourceWindowOffset` for differing window origins. Do not estimate button coordinates or store widget-specific anchor positions in services.

`expandFrom(source)` temporarily hides and disables the source container while the expanding surface is showing, then restores its original bindings after the collapse finishes. Keep this replacement behavior in the shared component so the original icons and background never show through the expanding panel.

Use `ExpandingContainer.expansionMode: "below"` for dropdowns that preserve the source. This opens beneath its captured rectangle with `sourceGap` from shared spacing; source opacity and input remain untouched. Use `ExpandingPopup` as the fixed-size host: set `anchorName`, `popupWidth`, and `popupHeight`, register through `WidgetEndpoint`, and pair `dismissed` with `Widgets.closed`. Its top-strip input hole leaves bar buttons clickable. The default `"replace"` container mode continues to hide/disable its source until collapse finishes.

Bar dropdowns use `Spacing.barPopupGap` for their gap below the bar. `ExpandingPopup` normalizes the source's bottom edge to at least `Sizing.barHeight + Spacing.barTopMargin`, so shorter buttons and full bar sections produce the same vertical gap. Keep this alignment in the shared host rather than adding offsets in individual widgets.

Use `components/StyledDropdown.qml` (`import qs.components`) for selection dropdowns. It supports string lists or object lists with `textRole`, provides keyboard selection and accessible button behavior, and supplies shared container styling and entry/exit animations. Its popup uses a fixed Quickshell layer-shell window to work with Wayland layer-shell hosts and avoid clipping inside expanding surfaces. Handle `activated(index)` to apply selection; keep models and selected-index bindings in their backing service.

Overlay popup and dropdown input masks must subtract `components/BarInputHole.qml` after their other regions so topbar buttons remain clickable. It follows the per-screen visible bar edge. Release full-screen dismissal input when closing starts; switching widgets must not wait for exit animations.

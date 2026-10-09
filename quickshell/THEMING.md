# Theming

The default style is weathered iron: near-black blue-grey surfaces, bone-silver
accents, etched grain, thin borders, and tight corners inspired by the
Death Above Life wallpaper. Set `Theme.metalStyle` to `false` to restore the
live Matugen palette and softer surfaces. Matugen continues to update other
applications while metal styling is active.

`StyledContainer` shares a cached SVG grain tile across surfaces; transparent
controls remain clear. Adjust `Theme.surfaceTextureOpacity` for the amount of
wear. Body text uses Fira Sans; headings use the installed 28 Days Later face
(with system fallback if unavailable). Typography and corner tokens live in
`Theme.qml`; the cold metal color roles live in `Colors.qml`.

Matugen renders `matugen/templates/matugen-quickshell.json` to
`~/.config/quickshell/colors.json`. `services/Colors.qml` watches this file and
updates color bindings without restarting the shell. Until it exists, the
shell uses a built-in dark Material palette when the metal style is disabled.

Generate a palette using the existing Matugen configuration:

```sh
matugen image /path/to/wallpaper -m dark
# Or use -m light for a light palette.
```

This also runs your other configured templates and wallpaper command. The
Quickshell background follows the wallpaper picker selection; running Matugen
from a terminal changes colors but does not change the picker selection.

Use `components/containers/StyledContainer.qml` for every visual container, including bars, tooltips, popups, cards, and widget backgrounds. It supplies shared surface color, radius, and border defaults; override these with theme tokens as needed. Keep window behavior separate and use normal anchors/layouts for its children.

Use shared tokens in components:

```qml
import qs.services
import qs.config
import qs.components.containers

StyledContainer {
    color: Colors.primaryContainer
    radius: Theme.radius
    Text {
        text: "Example"
        color: Colors.onPrimaryContainer
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
```

`Colors` exposes Material roles in camelCase, including `primary`, `onPrimary`,
`surfaceContainer`, `onSurface`, `outlineVariant` and error/container pairs.
Use matching `on*` roles for readable text. `panel`, `text`, `textMuted`, `border`
and `accent` provide common shell aliases. `Colors.withAlpha(color, opacity)`
adds transparency without embedding alpha in generated colors.

`Theme` holds typography, radii, wallpaper transition timing and panel opacity. `Spacing`
and `Sizing` hold layout tokens. The compatibility `success` alias maps to
`tertiary`, an accent rather than a guaranteed green status color.

If you use a custom XDG_CONFIG_HOME, update Matugen's Quickshell output_path to
that directory too. Start the checkout directly with `qs -p ~/dotfiles/quickshell`.

References: [Quickshell FileView](https://quickshell.org/docs/v0.3.2/types/Quickshell.Io/FileView/)
and [Matugen templates](https://github.com/InioX/matugen/wiki/Configuration).

## Wallpaper picker

Click **Wallpapers** in the right side of the bar to browse thumbnails from
`dotfiles/wallpapers`, including subdirectories. Search filters filenames, and
Refresh picks up newly added images. Supported formats: JPG, JPEG, PNG, WebP, BMP.

Selecting an image regenerates all configured Matugen application themes in dark mode, changes the
background on all monitors, and saves the selection to
`$XDG_STATE_HOME/quickshell/wallpaper.json` (default `~/.local/state`). The shell
restores this selection on launch, falling back to `assets/Wallpaper.jpg` if the
saved image is missing. Failed generation keeps the existing selection and shows
an error in the picker.

The picker requires Python 3 and Matugen. It uses a temporary copy of
`matugen/config.toml`, keeping all application templates and their reload hooks.
The wallpaper command is disabled in this copy so Quickshell renders the selected
image with its crossfade. Applications that do not watch their theme files need
a reload hook or restart to display the generated colors.

Wallpaper changes use a 700 ms crossfade after the next image finishes loading.
Adjust `Theme.wallpaperTransitionDuration` to change the speed. Selections made
during a fade are applied after it finishes, using the latest selection.

## Application launcher

Press **Super + Ctrl + Return** to open the app launcher on the focused monitor.
Type to fuzzy-search app names, generic names, keywords, and desktop IDs.
Use Up/Down or Tab/Shift+Tab to select, Enter to launch, and Escape or a click
outside the panel to close. Clicking a result also launches it. Reopening the
launcher clears the search, matching the previous Rofi shortcut behavior.

The launcher uses `CenteredPopup` and `StyledContainer` with shared theme tokens.
`Sizing.launcherWidth`, `launcherHeight`, `launcherRowHeight`, and
`launcherIconSize` control its dimensions. `scripts/app-launcher.sh` calls the
`launcher.open` IPC method; Hyprland starts this Quickshell configuration on login.
App discovery uses Quickshell DesktopEntries, and `gtk-launch` launches the
desktop entry, including applications that request a terminal.

## Bar widgets

The bar hides until the pointer reaches the top edge of a monitor and overlays
windows without reserving desktop space. It stays visible while hovered and
hides after `Theme.barHideDelay` milliseconds when the pointer leaves.
`Sizing.barRevealHeight` sets the transparent edge trigger height.

The left side shows the current media artist/title and previous, play/pause,
and next controls through MPRIS. Playing players take priority, then paused
players. With no player, it shows "No media playing" and hides controls.
Unsupported player actions are disabled. Long track labels are truncated;
hover to read the full label.

The right side shows the wallpaper picker, network adapter icon, output volume,
optional laptop battery, and clock. Hover for connection details or the full
date. Click volume to toggle mute; scroll to adjust it in 5% steps, up to 100%.
Network state comes from NetworkManager, audio from PipeWire, and battery state
from UPower. Missing services show disconnected/unavailable states.

`config/ShellConfig.qml` controls volume step and device type (`auto`, `laptop`, or `desktop`). Shared
`services/Environment.qml` exposes `hasBattery`, `isLaptop`, `showBattery`, and
battery state for other widgets. Automatic detection counts present internal
batteries, excluding UPS and peripheral batteries; the battery indicator stays
hidden without a usable internal battery.

Service references: [Networking](https://quickshell.org/docs/v0.3.1/types/Quickshell.Networking/Networking/),
[PipeWire](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Pipewire/Pipewire/),
and [UPower](https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.UPower/UPowerDevice/).

## Centered popups

`components/containers/CenteredPopup.qml` provides a screen-centered overlay with
`StyledContainer`, shared padding, Escape and click-outside dismissal. It fits
inside the screen without reserving desktop space. Its children become the
content of the padded surface. Set `screen` to the invoking window's screen;
call `open()`, `close()`, or `toggle()` to control it.

```qml
import QtQuick
import qs.components.containers
import qs.config
import qs.services

CenteredPopup {
    id: dialog
    // screen: invokingWindow.screen
    // popupWidth/popupHeight default to Sizing.popupWidth/popupHeight.
    Text {
        anchors.centerIn: parent
        text: "Hello"
        color: Colors.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
```

The wallpaper picker uses this component and focuses its search field on open.

## Bar visibility locks

The auto-hiding bar stays revealed while hovered or while an interaction holds a
lock for its monitor. Tooltips hold a lock and pass pointer input through;
`CenteredPopup` holds a lock while open (`keepBarVisible` defaults to true).
After the last lock releases and the pointer leaves, the usual hide delay resumes.

Future custom widget expansions should include an automatically managed lock:

```qml
import qs.components

BarVisibilityLock {
    screen: invokingWindow.screen
    active: expansion.visible
}
```

Use the screen of the bar that opened the expansion. Each owner holds its own
lock, so overlapping popups cannot release each other's locks. Changing `active`
to false, changing screens, or destroying the owner releases its lock.
`BarVisibility.acquire(screen)` and `release(token)` are also available for
imperative integrations, which must pair each acquisition with a release.

## Split bar surfaces

The bar has independent rounded left, center clock, and right `StyledContainer`
surfaces with click-through gaps. All sections share the reveal animation and
per-monitor visibility locks. `Spacing.screenTopMargin` sets the shared top inset for the bar, notification
toasts, and top-aligned popup surfaces. Set it to zero for flush placement.
`Spacing.barTopMargin` and `Spacing.notificationTopMargin` default to that inset
and can override it independently. `ScreenLayout` supplies the shared bar bottom,
popup top, and animated notification offset; use it for new top-aligned widgets.
`Spacing.barMargin` keeps the horizontal inset.
`Spacing.barSectionGap` controls the minimum gap around the clock.

## Clock expansion

Click the center clock to expand its container into a two-section menu. The left
section holds the calendar and selected-date agenda, with an outline for today
and a filled selected date. The right Appearance section opens the wallpaper
selector and holds brightness controls when available. Opening the selector
collapses the clock menu. The clock grows while the panel widens and its content
slides and fades into view. Click
the time again or press Escape to collapse it. Month arrows and Today navigate
the calendar; selecting a day updates the agenda placeholder. Settings and
events are placeholders for future integrations.

Brightness appears only when `brightnessctl` reports a backlight device; its
slider changes that device and refreshes the reported level. Desktop monitors
without a backlight device do not show this control. `Sizing.clockMenuWidth`,
`clockMenuHeight`, `calendarHeight`, and `Theme.clockExpandedFontSize` control
the expansion; animations use `config/Animations.qml` presets.

## Interaction animations

`config/Animations.qml` controls snappy interaction transitions: bar reveals use
`revealDuration` (160 ms), menu expansion uses `expandDuration` (180 ms), and
collapse uses `collapseDuration` (130 ms), each with its own easing. Set `enabled`
to false for instant transitions. The clock keeps a fixed window and calendar
layout, scales fixed-size clock text, and fades/slides cached content while the
surface reveals it. Its input mask follows the visible panel so hidden areas
remain click-through.

Shared centered dialogs use expand/collapse presets and animate their surface
with a vertical translation and opacity inside a fixed window. Tooltips use
reveal/collapse presets. Notification toasts slide horizontally from and back
to the right screen edge at full opacity. Their display snapshots and delegates
remain alive until the exit completes; surviving cards then move into position.
Model updates preserve existing cards, so receiving another notification does
not replay the whole stack. Interaction color feedback uses `feedbackDuration`
and `feedbackEasing`, and all these transitions respect `Animations.enabled`.

## Widget launcher and session menu

Super+Q toggles the Quickshell power menu, replacing wlogout. It preserves the
five configured actions and shortcuts: L Lock, E Log Out, U Suspend, R Restart,
and S Power Off. Actions use `hypr/scripts/power.sh`; Escape or clicking outside
closes the menu. Tab and Enter/Space support keyboard button navigation.

Super+Ctrl+Return opens the application launcher. Both bindings use the shared
helper, selecting the currently focused monitor and targeting the running shell:

```sh
~/dotfiles/scripts/widget.sh power          # toggle (default)
~/dotfiles/scripts/widget.sh launcher open
~/dotfiles/scripts/widget.sh power close
~/dotfiles/scripts/widget.sh list
```

`scripts/app-launcher.sh` and `scripts/wlogout.sh` remain compatibility wrappers.
The shell must be running; the helper tries the installed config path and then
the checkout path. It does not spawn additional shell instances.

Register future widgets through `WidgetEndpoint`, add their module to
`shell.qml`, and use the same helper without adding another IPC handler:

```qml
import qs.components
import qs.services

WidgetEndpoint {
    name: "example"
    openAction: screenName => {
        dialog.screen = Widgets.screenFor(screenName)
        dialog.open()
    }
    closeAction: () => dialog.close()
}
// On the dialog: onDismissed: Widgets.closed("example")
```

`WidgetHost` provides the `widgets` IPC target with open/toggle/close/list.
The registry closes the previous registered widget before opening another, and
endpoints unregister when destroyed. Keep dismissal notifications paired with
registration so toggling reflects Escape/click-outside closures too.

## Media playback

Click the playing track in the bar to open the `media` dropdown. It uses faded
track artwork behind the title, artist, seek timeline, previous/play-pause/next
controls, and output volume. Unsupported player actions and seeking are disabled.
The volume panel and media panel share `components/StyledSlider.qml`.
`Sizing.mediaPanelWidth/mediaPanelHeight` and `Theme.mediaArtworkOpacity` control
its layout and background. It also opens with `scripts/widget.sh media`.

## Notifications

Incoming cards use `Spacing.notificationTopMargin` (0 by default) while the bar
is hidden and `Spacing.notificationBarGap` below the revealed bar. The stack
follows the bar's animated bottom edge per monitor, inside a fixed-size window
whose input mask follows the cards.

Quickshell now owns the desktop notification service; SwayNC is removed from
Hyprland autostart. The right bar bell shows the retained notification count and
expands a notification panel from the bell position. Incoming cards appear on the focused
monitor, with up to three visible at once. Clicking a card opens the list;
application action buttons invoke their supplied actions. Hovering pauses a
card's timeout and holds the bar visible.

The list supports Do not disturb, Clear all, and individual dismissal. DND
suppresses incoming cards while retaining regular notifications in the list.
Regular cards remain in history after their toast timeout; transient notifications
skip history. History is capped at 100 entries and survives QML reloads, but is
not stored across shell restarts. DND is a session setting. All surfaces use
StyledContainer and the shared Matugen colors and sizing/animation tokens.

```sh
~/dotfiles/scripts/widget.sh notifications       # toggle on the focused monitor
~/dotfiles/scripts/widget.sh notifications open
notify-send "Hello" "A test notification"
```

## Reusable expanding surfaces

Use `ExpandingContainer` for shared collapsed/expanded dimensions, animation
progress, clipping, and visibility locks. Put stable-size content inside
`ExpandingContent { surface: panel }`; set `topInset` when reserving space for a
header. Both the clock and notification center use these components. Keep the
host window fixed-size and derive its input mask from the visible surface.
Notification actions, DND, Clear all, outside-click dismissal, and Escape remain
available through `widget.sh notifications` and the bar bell.

## Clipboard history

**Super + V** opens the `clipboard` widget through `scripts/widget.sh clipboard`.
The existing `wl-paste --watch cliphist store` history backend is preserved.
Search previews, navigate with Up/Down or Tab/Shift+Tab, and press Enter to copy.
Ctrl+Delete or the Delete button removes an entry; Clear history requires a
second confirmation click. Escape closes the panel. Binary entries use their
cliphist preview and copy their original bytes. The old `scripts/cliphist.sh`
entry point forwards to the viewer rather than starting Rofi.

The widget refreshes while open using `Theme.clipboardPollInterval`; its size
is controlled by `Sizing.clipboardWidth`, `clipboardHeight`, and
`clipboardRowHeight`. It requires `cliphist`, `wl-copy`, and Python 3.

## Volume output selection

The compact volume panel includes a `StyledDropdown` for hardware/virtual
PipeWire output sinks (excluding application streams), followed by the volume
slider. Selecting an output sets PipeWire's preferred default audio sink; the
bar, volume level, and mute control follow the active default. Device hotplug
updates the choices. `Sizing.volumePanelWidth/Height` controls the panel; shared
`dropdownHeight`, `dropdownRowHeight`, and `dropdownMaxHeight` control selectors.
Use `StyledDropdown` with a string list, or an object list and `textRole`; handle
`activated(index)` to apply a selection.

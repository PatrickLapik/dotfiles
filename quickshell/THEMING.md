# Theming

Set `ShellConfig.uiScale` to scale the whole shell: `1.0` preserves the default
size, `1.1` makes it roughly 10% larger, and `0.9` makes it smaller. Text, icons,
controls, spacing, borders, corners, and default panel dimensions share this
scale. This operates in logical pixels, on top of compositor output scaling;
do not copy a monitor's DPI scale into this setting. Invalid or nonpositive
scales fall back to `1.0`. Counts, animation timings, and image source resolutions
are unaffected.

Configure each widget in `Sizing.popupLimits`. Both `width` and `height` accept:

- A number: logical pixels multiplied by `uiScale`.
- A percentage string: a fraction of available space on the popup's monitor,
  after the host's margins and, for dropdowns, the space above the popup.
- `"content"`: fit contents, including padding, within the configured bounds.

`minWidth`, `maxWidth`, `minHeight`, and `maxHeight` accept numbers or percentages.
Explicit axes with no maximum can use all available space. Minimums default to
zero. Available space takes priority over all bounds, and a minimum larger than
its maximum is clamped to that maximum. Percentages are not multiplied by UI scale.

```qml
launcher: {
    width: "40%", minWidth: 480, maxWidth: 900,
    height: "content", maxHeight: "70%"
},
volume: {
    width: 360,
    height: "content", maxHeight: 160
}
```

Launcher, notifications, and wallpapers start with relative widths. Smaller
panels fit their contents. Lists and grids scroll when they reach their height
limit. Setting an explicit height such as `"70%"` reserves that space even when
there are few items.

Omitting an axis retains the legacy content-fitting behavior controlled by
`ShellConfig.popupHugContents` (or per-widget `hugContents`). Existing panel
width/height tokens provide fallback maximums for omitted axes. Explicit numeric,
percentage, and `"content"` rules take priority over this switch. Invalid dimension
values fall back to the default behavior.

Hosts keep native windows fixed and hold content dimensions steady during entry
and exit. Sizing is resolved separately for the monitor opening each popup.

The default style uses the live Matugen palette, opaque rounded surfaces,
subtle color highlights, and Adwaita Sans. Body text is regular, controls are medium,
and headings are semibold. Typography and corner tokens live in `Theme.qml`.

`StyledContainer` paints a solid base with a subtle primary, secondary, and
tertiary gradient and no decorative border. It uses native Qt fills on both
hardware and software renderers. `Theme.containerHighlightOpacity` controls
fill tinting. Override
`highlightColor`, `highlightSecondary`, or `highlightTertiary` for a surface's
palette roles. `highlightOpacity: 0` keeps exact fills for masks and flat
controls, and fully transparent fills remain clear.

`Theme.panelOpacity` defaults to 1 so panels remain readable over any wallpaper.
All top bar sections use the same shared container fill: primary at the top,
secondary in the middle, and tertiary at the bottom, over an opaque surface base.
They share the same gradient strength and use the standard surface text color.

Backdrop blur is enabled by `Theme.backdropBlurEnabled`, independently of
`Theme.panelOpacity`. It applies behind the bar sections, popup panels, dropdowns,
and notification toasts. `BackdropBlurRegion` follows each visible
surface's rounded bounds and animation; transparent fullscreen dismissal areas
are excluded. Nested controls share their host's backdrop.
Media artwork opacity is `Theme.mediaArtworkOpacity * Theme.panelOpacity`, so
its overlay becomes more transparent together with the panel.

Adjust blur strength in `hypr/conf/blur.lua`: `size` controls the blur radius and
`passes` controls the number of blur passes. Current defaults are 12 and 4.
These are compositor-wide settings and also affect normal app windows. The
`enabled` setting there is Hyprland's master switch; `backdropBlurEnabled` only
controls Quickshell's requests. Reload Hyprland after changing the Lua settings.
Opaque fills hide the effect; lower `panelOpacity` to reveal more of it.
Quickshell uses the compositor's `ext-background-effect-v1` support rather than
sampling the wallpaper or blurring the container's text and icons.

Set `Theme.metalStyle` to `true` for the optional cold iron palette, tighter
corners, and grain inspired by the Death Above Life wallpaper.
Both styles use the same typography. `StyledContainer` shares a cached SVG grain
tile across metal surfaces; `Theme.surfaceTextureOpacity` controls its strength.
Matugen continues to update other applications while metal styling is active.

Use `StyledButton` for text actions and `StyledIconButton` for icon actions.
The latter uses `ShellIcon`, the common drawn icon system for status, playback,
calendar navigation, and session controls. Set `flat: true` for quiet actions;
checked controls and keyboard focus retain their shared indication. `RoundedImage`
provides consistent rounded previews and artwork.

Topbar controls set `highlightInteractions: false` and use stable backgrounds;
hovering, pressing, or opening a widget does not tint them. Keyboard focus still
has an outline. Selection dropdowns use plain rows, a neutral navigation state,
and a checkmark for the applied selection. Long option names wrap to two lines.

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

Use `components/containers/StyledContainer.qml` for every visual container, including bars, popups, cards, and widget backgrounds. It supplies shared surface color, radius, and border defaults; override these with theme tokens as needed. Keep window behavior separate and use normal anchors/layouts for its children.

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

Click **Wallpapers** at the bottom of the clock dropdown to browse thumbnails from
`dotfiles/wallpapers`, including subdirectories. Search filters filenames.
The refresh icon picks up newly added images. Supported formats: JPG, JPEG, PNG,
WebP, BMP. The current wallpaper has an accent outline and checkmark. The
picker is registered as `wallpapers` and also opens with `scripts/widget.sh wallpapers`.

The wallpaper, clipboard, and app launcher menus use `components/PopupToolbar.qml` for their
title, search field, count, and optional trailing actions. Keep filtering and
keyboard actions in the owning widget through `searchText` and
`searchKeyPressed`; use `focusSearch()` when opening. Both menus keep a stable
height while their results scroll.

Selecting an image regenerates all configured Matugen application themes in dark mode, changes the
background on all monitors, and saves the selection to
`$XDG_STATE_HOME/quickshell/wallpaper.json` (default `~/.local/state`). The shell
restores this selection on launch, falling back to `assets/Wallpaper.jpg` if the
saved image is missing. Failed generation keeps the existing selection and shows
an error in the picker.

The **Color scheme** dropdown selects Matugen's `--type` from all ten supported
schemes, defaulting to `scheme-tonal-spot`. Changing it regenerates themes for the
current wallpaper. The scheme is saved alongside the wallpaper after successful
generation and reused for later selections and shell restarts. Before selecting
a first wallpaper, the dropdown chooses the scheme to use for that selection.

The picker requires Python 3 and Matugen. It uses a temporary copy of
`matugen/config.toml`, keeping all application templates and their reload hooks.
The wallpaper command is disabled in this copy so Quickshell renders the selected
image with its crossfade. Applications that do not watch their theme files need
a reload hook or restart to display the generated colors.

Wallpaper changes use a 700 ms crossfade after the next image finishes loading.
Adjust `Theme.wallpaperTransitionDuration` to change the speed. Selections made
during a fade are applied after it finishes, using the latest selection.

## Application launcher

Press **Super + Ctrl + Return** to open a single search list of installed apps
and running windows. With an empty search, apps are ordered by recent and frequent
usage, with alphabetical ties. Typing matches app names, keywords, IDs, and window
titles; exact app names take priority and usage boosts close matches.

Each app's launch action comes first, followed by its open windows as indented,
selectable children. Searching an app shows its windows; searching a window title
shows matching windows below their parent app. Unmapped windows remain searchable.
Enter on an app launches it even if it is already running (the app decides whether
to create a new window); Enter on a window closes the launcher and focuses that
window through Hyprland’s address-based focus dispatcher, using `hl.dsp.focus`
in Lua sessions and `focuswindow` in legacy sessions. The live window
address identifies the target even when several windows have the same title.
Use Up/Down or Ctrl+N/Ctrl+P to navigate and scroll through all entries, including
child windows. Tab moves between controls; Escape closes the launcher.

Arithmetic queries such as `(12 + 8) / 5` show a result that Enter copies.
Prefix with `=` to calculate a plain number. Supported operations are `+ - * / %`
(remainder), `^` (power), parentheses, `pi`, `e`, and `sqrt`, `abs`, `round`,
`floor`, and `ceil`. The calculator parses arithmetic without executing code;
incomplete expressions, division by zero, and nonfinite results are rejected.

The `Applications` service watches focused Wayland windows while the shell runs,
including apps opened outside the launcher. Focus must remain for
`Theme.launcherFocusDelay`; repeated visits within `launcherVisitInterval` do not
inflate usage counts. Launcher activations update recency immediately. History
starts when tracking is enabled; it cannot recover past sessions retroactively.

Tracking preference and a bounded history of app IDs, timestamps,
and counts are saved atomically to `$XDG_STATE_HOME/quickshell/app-history.json`
(default `~/.local/state`). Window titles and search queries are not saved.
**History** exposes tracking on/off and a two-step clear-history action. Disabling tracking keeps existing history. Uninstalled
apps are removed on subsequent saves once the app catalog is populated. Optional
`ShellConfig.launcherAppAliases` maps unusual window app IDs to desktop entry IDs.

The launcher uses the shared centered popup and borderless container styling.
`Sizing.popupLimits.launcher` sets a stable panel size while searching; the
list scrolls within the available space. Dimensions are in `Sizing.qml`. The launcher uses the shared `widgets` IPC endpoint.
App discovery uses Quickshell DesktopEntries, `gtk-launch` opens apps, and Python 3
handles state persistence.

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

The right side shows notifications, network state, microphone level, output
volume, brightness when a backlight is available, and an optional laptop battery. The clock sits in the center. Hover for
connection and device details. Click an audio control to open its dropdown;
middle-click toggles mute and scrolling adjusts the level in 5% steps, up to 100%.
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
lock for its monitor. `CenteredPopup` holds a lock while open
(`keepBarVisible` defaults to true).
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

## Clock dropdown

Click the center clock to open a compact dropdown underneath it. The time and
full date lead into a calendar, with month arrows, Today, and keyboard-accessible
day buttons. The selected day has an accent fill; today uses accent text. The
footer opens the wallpaper picker.
There are no agenda or settings placeholders.

The clock button stays at its normal size, so the left and right bar sections
keep their layout throughout opening and closing. The `clock` widget uses a
per-monitor anchor and the shared registry. Opening another widget closes it;
clicking the clock again, pressing Escape, or clicking outside also dismisses it.
It can be opened with `scripts/widget.sh clock`.

`Sizing.popupLimits.clock`, `Sizing.calendarHeight`, and
`Theme.clockExpandedFontSize` control its layout; animations use
`config/Animations.qml` presets.

## Brightness dropdown

The sun button on the right side of the topbar opens the shared anchored popup
with a brightness slider and current percentage. It appears only when
`brightnessctl` reports a backlight device. The slider changes that device and
refreshes the reported level; errors appear below it.
Scroll over the sun button to adjust brightness without opening the popup.
`ShellConfig.brightnessStep` sets the percentage points per scroll step (default 5).

Use `Sizing.brightnessPanelWidth`, `Sizing.brightnessPanelHeight`, and
`Sizing.popupLimits.brightness` to configure its dimensions and content fitting.
It shares popup spacing, styling, dismissal, and animation presets with the
other bar dropdowns. Open it with `scripts/widget.sh brightness`.

## Interaction animations

`config/Animations.qml` controls snappy interaction transitions: bar reveals use
`revealDuration` (140 ms), menu expansion uses `expandDuration` (160 ms), and
collapse uses `collapseDuration` (100 ms), each with its own easing. Opacity uses
separate linear `fadeInDuration` (140 ms) and `fadeOutDuration` (100 ms) presets
so eased movement does not make the fade jump at the start. Popup travel uses
`Spacing.popupSlideOffset` (4 logical pixels before UI scaling). Set `enabled`
to false for instant transitions. Dropdowns keep fixed windows and content
layouts, fading/sliding cached content while their surfaces expand. Their input
masks release full-screen dismissal input as soon as closing starts; the bar
remains clickable throughout transitions.

Shared centered dialogs use expand/collapse presets and animate their surface
by growing from the center inside a fixed window. Notification toasts slide horizontally from and back
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
The centered menu uses compact rows with icons, labels, and right-aligned
shortcuts. A divider separates Restart and Power Off from the other actions;
Power Off uses the error accent without a permanent filled background.

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
controls. Unsupported player actions and seeking are disabled.
The volume panel and media panel share `components/StyledSlider.qml`.
`Sizing.popupLimits.media` and `Theme.mediaArtworkOpacity` control
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
Search previews, navigate with Ctrl+N/P, Up/Down, or Tab/Shift+Tab, and press Enter to copy.
Ctrl+Delete or the Delete button removes an entry; Clear history requires a
second confirmation click. Escape closes the panel. Binary entries use their
cliphist preview and copy their original bytes. The old `scripts/cliphist.sh`
entry point forwards to the viewer rather than starting Rofi.

History is prefetched at shell startup. Each opening waits for a fresh history
snapshot, then selects the newest entry and resets the scroll position before
revealing the panel. Refresh requests during a clipboard operation are queued.
Unchanged snapshots leave the list alone; changed entries update existing rows
by ID and preserve the selected entry and scroll position while browsing.
If an opening refresh fails, the panel shows cached history and the error.

The widget refreshes while open using `Theme.clipboardPollInterval`; its size
is controlled by `Sizing.popupLimits.clipboard` and
`Sizing.clipboardRowHeight`. It requires `cliphist`, `wl-copy`, and Python 3.

## Volume output selection

The compact volume panel includes a `StyledDropdown` for hardware/virtual
PipeWire output sinks (excluding application streams), followed by the volume
slider. The bar, volume level, and mute control follow the selected device. Selecting an
input or output moves current application streams to that device, including
applications pinned to another target. The selection is confirmed against the
audio graph before the UI updates; failures appear in the panel. Internal
Bluetooth/filter streams are excluded.

**Set as default** saves the selected input or output as WirePlumber's preferred
default for future applications and subsequent sessions. **Default** indicates
the selected device already has that preference. Selecting a device alone does
not replace the saved system default. The selected device falls back to the
system default if it disconnects. Device hotplug updates the choices.

The microphone panel includes a thin live input meter below its gain slider.
It follows the selected microphone and samples only while the panel is open
and the microphone is unmuted. Its fill uses a square-root scale to make quieter
sounds visible. `Sizing.audioInputMeterHeight` controls its thickness.

Switching requires Python 3, `pw-dump`, `pw-metadata`, and `wpctl`. The first two
PipeWire tools apply and verify routing; `wpctl` persists the default preference.
`Sizing.popupLimits.volume` and `microphone` control their panels; shared
`dropdownHeight`, `dropdownRowHeight`, and `dropdownMaxHeight` control selectors.
Use `StyledDropdown` with a string list, or an object list and `textRole`; handle
`activated(index)` to apply a selection. Its `currentIndex` stays bound to the
owning service, including asynchronous updates or failed changes.

## Lockscreen

Press **Super + Ctrl + L**, choose **Lock** from the session menu, or run
`scripts/widget.sh lock open`. Idle locking and locking before sleep use the
same independent Quickshell locker. Lock requests are idempotent; `close` cannot
unlock it. Hyprlock remains installed as the startup-failure fallback.

The layout follows the old Hyprlock setup: a blurred screenshot, Chuck Norris
jokes at the top left, a lock icon and password in the center, and a clock
and date at the bottom right. Colors follow the shared Matugen palette. Each
monitor gets its own lock surface. Missing screenshots fall back to a solid
palette background. Jokes refresh every minute with a cached/offline fallback;
network requests never hold up locking.

Edit `config/LockConfig.qml` for blur, dimming, joke refresh interval,
and PAM service. Lock dimensions and typography live in `Sizing.qml`,
`Spacing.qml`, and `Theme.qml` and follow `ShellConfig.uiScale`. The default PAM
service is the existing `/etc/pam.d/hyprlock`; no system PAM files are changed.

`lockscreen.qml` runs separately from the regular shell with config auto-reload
disabled during the lock. `scripts/lock.py` serializes launches, bounds screenshot
capture time, stores captures in a private runtime directory, and removes them
when the locker exits. Only PAM success releases the session lock. Escape clears
the entry; it does not dismiss the lockscreen. The status-only `sessionLock`
IPC target exposes no unlock method. Lock content fades and slides in with the
shared `Animations.qml` expansion preset while the captured background blurs and
dims. Successful authentication reverses the transition with the collapse preset;
the session lock is released only after that animation finishes. Setting
`Animations.enabled` to false makes both transitions immediate.

Hypridle uses `inhibit_sleep = 3` so suspend waits for compositor confirmation of
the lock, rather than merely the launch of the command. See the
[Quickshell session-lock documentation](https://quickshell.org/docs/v0.2.1/types/Quickshell.Wayland/WlSessionLock/),
[PAM API](https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Pam/PamContext/),
and [Hypridle sleep inhibition](https://wiki.hypr.land/hypr-ecosystem/user/hypridle/).

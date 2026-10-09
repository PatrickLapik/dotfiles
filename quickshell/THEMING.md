# Theming

Matugen renders `matugen/templates/matugen-quickshell.json` to
`~/.config/quickshell/colors.json`. `services/Colors.qml` watches this file and
updates color bindings without restarting the shell. Until it exists, the
shell uses a built-in dark Material palette.

Generate a palette using the existing Matugen configuration:

```sh
matugen image /path/to/wallpaper -m dark
# Or use -m light for a light palette.
```

This also runs your other configured templates and wallpaper command. The
Quickshell background follows the wallpaper picker selection; running Matugen
from a terminal changes colors but does not change the picker selection.

Use shared tokens in components:

```qml
import qs.services
import qs.config

Rectangle {
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

`Theme` holds typography, radii, animation timings and panel opacity. `Spacing`
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

Selecting an image generates a dark Matugen palette for Quickshell, changes the
background on all monitors, and saves the selection to
`$XDG_STATE_HOME/quickshell/wallpaper.json` (default `~/.local/state`). The shell
restores this selection on launch, falling back to `assets/Wallpaper.jpg` if the
saved image is missing. Failed generation keeps the existing selection and shows
an error in the picker.

The picker requires Python 3 and Matugen. It uses a temporary Matugen config to
generate only the Quickshell palette; other application templates and wallpaper
daemons are not invoked. Quickshell renders the selected image itself.

Wallpaper changes use a 700 ms crossfade after the next image finishes loading.
Adjust `Theme.wallpaperTransitionDuration` to change the speed. Selections made
during a fade are applied after it finishes, using the latest selection.

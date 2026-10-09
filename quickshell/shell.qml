import Quickshell
import qs.modules.clipboard
import qs.modules.background
import qs.modules.launcher
import qs.modules.bar
import qs.modules.volume
import qs.modules.media
import qs.modules.power
import qs.modules.notifications
import qs.components

ShellRoot{
    Background{}
    Bar{}
    WidgetHost{}
    ClipboardViewer{}
    AppLauncher{}
    PowerMenu{}
    VolumePanel { }
    MicrophonePanel {}
    MediaPanel {}
    NotificationCenter{}
    NotificationToasts{}
}

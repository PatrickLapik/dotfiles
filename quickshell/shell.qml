import Quickshell
import qs.modules.clipboard
import qs.modules.launcher
import qs.modules.bar
import qs.modules.wallpapers
import qs.modules.volume
import qs.modules.media
import qs.modules.power
import qs.modules.notifications
import qs.modules.lock
import qs.modules.bluetooth
import qs.modules.network
import qs.components

ShellRoot{
    LockLauncher{}
    Bar{}
    ClockMenu{}
    BrightnessPanel{}
    WallpaperPicker{}
    WidgetHost{}
    ClipboardViewer{}
    AppLauncher{}
    PowerMenu{}
    VolumePanel { }
    MicrophonePanel {}
    NetworkPanel {}
    BluetoothPanel {}
    MediaPanel {}
    NotificationCenter{}
    NotificationToasts{}
}

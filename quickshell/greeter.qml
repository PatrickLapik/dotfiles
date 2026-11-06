import QtQuick
import QtQuick.Window
import Quickshell
import qs.config
import qs.modules.greeter

ShellRoot {
    readonly property bool loginMode: Quickshell.env("DOTFILES_GREETER_MODE") === "login"
    Window {
        flags: loginMode ? Qt.Window | Qt.FramelessWindowHint : Qt.Window
        visibility: loginMode ? Window.FullScreen : Window.Windowed
        title: loginMode ? "Dotfiles login" : "Dotfiles greeter preview"
        width: Sizing.greeterPreviewWidth
        height: Sizing.greeterPreviewHeight
        color: "transparent"
        onClosing: event => {
            if (loginMode) event.accepted = false
            else Qt.quit()
        }
        GreeterView {
            anchors.fill: parent
            wallpaper: Quickshell.env("DOTFILES_GREETER_WALLPAPER")
            preview: !loginMode
            initialUser: loginMode ? Quickshell.env("DOTFILES_GREETER_USER") : Quickshell.env("USER")
        }
    }
}

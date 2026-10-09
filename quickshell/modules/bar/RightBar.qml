import QtQuick
import QtQuick.Layouts
import qs.services
import qs.config
import qs.modules.wallpapers

RowLayout {
    Layout.fillWidth: false
    Layout.alignment: Qt.AlignRight
    implicitHeight: parent.height
    
    spacing: Spacing.md

    WallpaperPicker {}

    Text {
        color: Colors.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        text: Time.time
    }
}

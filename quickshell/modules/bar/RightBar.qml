import QtQuick
import QtQuick.Layouts
import qs.services

RowLayout {
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignRight
    implicitHeight: parent.height
    
    Text {
        color: "#FFFFFF"
        text: Time.time
    }
}

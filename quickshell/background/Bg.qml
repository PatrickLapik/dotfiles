import Quickshell
import QtQuick

PanelWindow {
    aboveWindows: false
    focusable: false
    color: 'transparent'

    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onPositionChanged: {
            const normalizedX = mouseX / width;
            const normalizedY = mouseY / height;

            image.x = (normalizedX - 0.5) * 5;
            image.y = (normalizedY - 0.5) * 5;
        }
    }

    Image {
        id: image
        source: '/home/patrick/dotfiles/wallpapers/dark-green-leaves.jpg'
        width: parent.width + 80
        height: parent.height + 80
        fillMode: Image.PreserveAspectCrop
        Behavior on x {
            NumberAnimation {
                duration: 100
            }
        }
        Behavior on y {
            NumberAnimation {
                duration: 100
            }
        }
    }
}

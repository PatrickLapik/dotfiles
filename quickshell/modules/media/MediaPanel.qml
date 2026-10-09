pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.components.containers
import qs.config
import qs.services

Scope {
    WidgetEndpoint {
        name: "media"
        openAction: screenName => { popup.screen = Widgets.screenFor(screenName); popup.open() }
        closeAction: () => popup.close()
    }
    ExpandingPopup {
        id: popup
        anchorName: "media"
        popupWidth: Sizing.mediaPanelWidth
        popupHeight: Sizing.mediaPanelHeight
        onDismissed: Widgets.closed("media")
        radius: Theme.radiusSmall
        backgroundContent: Image {
            anchors.fill: parent
            source: Media.artUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            opacity: Theme.mediaArtworkOpacity
            visible: status === Image.Ready
        }
        FrameAnimation {
            running: popup.expanded && Media.playing && Media.player.positionSupported && !seek.pressed
            onTriggered: if (Media.player) Media.player.positionChanged()
        }
        ColumnLayout {
            anchors.fill: parent
            spacing: Spacing.sm
            RowLayout {
                Layout.fillWidth: true
                Text { Layout.fillWidth: true; text: "Now playing"; color: Colors.text; font.weight: Theme.headingFontWeight; font.family: Theme.headingFontFamily; font.pixelSize: Theme.fontSizeLarge; font.letterSpacing: Theme.headingLetterSpacing }
                StyledButton { text: "×"; Accessible.name: "Close playback controls"; onClicked: popup.close() }
            }
            ScrollingText { Layout.fillWidth: true; text: Media.title; color: Colors.text; font.weight: Theme.emphasisFontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize;  }
            ScrollingText { Layout.fillWidth: true; text: Media.artist || (Media.available ? Media.player.identity : "No player available"); color: Colors.textMuted; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
            StyledSlider {
                id: seek
                Layout.fillWidth: true
                from: 0; to: Math.max(1, Media.length)
                enabled: Media.canSeek
                Accessible.name: "Playback position"
                onMoved: Media.seekTo(value)
                Binding { target: seek; property: "value"; value: Media.position; when: !seek.pressed }
            }
            RowLayout {
                Layout.fillWidth: true
                Text { text: Media.formatTime(seek.value); color: Colors.textMuted; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                Item { Layout.fillWidth: true }
                Text { text: Media.length > 0 ? Media.formatTime(Media.length) : "—"; color: Colors.textMuted; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Spacing.md
                StyledButton { text: "⏮"; Accessible.name: "Previous track"; enabled: Media.available && Media.player.canGoPrevious; onClicked: Media.previous() }
                StyledButton { text: Media.playing ? "⏸" : "▶"; Accessible.name: Media.playing ? "Pause" : "Play"; enabled: Media.available && Media.player.canTogglePlaying; onClicked: Media.toggle() }
                StyledButton { text: "⏭"; Accessible.name: "Next track"; enabled: Media.available && Media.player.canGoNext; onClicked: Media.next() }
            }
        }
    }
}

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
        backgroundContent: RoundedImage {
            anchors.fill: parent
            source: Media.artUrl
            sourceSize.width: Sizing.mediaPanelWidth * 2
            sourceSize.height: Sizing.mediaPanelHeight * 2
            radius: Theme.radius
            // Artwork is part of the panel surface and follows its transparency.
            opacity: Theme.mediaArtworkOpacity * Theme.panelOpacity
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
                Text { Layout.fillWidth: true; text: "Now playing"; color: Colors.text; font.weight: Theme.headingFontWeight; font.family: Theme.headingFontFamily; font.pixelSize: Theme.fontSizeSmall; font.letterSpacing: Theme.headingLetterSpacing }
            }
            ScrollingText { Layout.fillWidth: true; text: Media.title; color: Colors.text; font.weight: Theme.emphasisFontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeLarge;  }
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
                Text { text: Media.formatTime(seek.value); color: Colors.textMuted; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.features: { "tnum": 1 } }
                Item { Layout.fillWidth: true }
                Text { text: Media.length > 0 ? Media.formatTime(Media.length) : "—"; color: Colors.textMuted; font.weight: Theme.fontWeight; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.features: { "tnum": 1 } }
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Spacing.md
                StyledIconButton { iconName: "previous"; Accessible.name: "Previous track"; enabled: Media.available && Media.player.canGoPrevious; onClicked: Media.previous() }
                StyledIconButton { iconName: Media.playing ? "pause" : "play"; flat: false; padding: Spacing.sm; Accessible.name: Media.playing ? "Pause" : "Play"; enabled: Media.available && Media.player.canTogglePlaying; onClicked: Media.toggle() }
                StyledIconButton { iconName: "next"; Accessible.name: "Next track"; enabled: Media.available && Media.player.canGoNext; onClicked: Media.next() }
            }
        }
    }
}

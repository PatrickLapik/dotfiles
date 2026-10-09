pragma Singleton
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    readonly property var player: Mpris.players.values.find(p => p.isPlaying)
        || Mpris.players.values.find(p => p.playbackState === MprisPlaybackState.Paused)
        || Mpris.players.values[0] || null
    readonly property bool available: !!player
    readonly property bool playing: available && player.isPlaying
    readonly property string title: available ? (player.trackTitle || player.identity || "Unknown track") : "No media playing"
    readonly property string artist: available ? player.trackArtist : ""
    readonly property string artUrl: available ? player.trackArtUrl : ""
    readonly property real length: available && player.lengthSupported ? Math.max(0, player.length) : 0
    readonly property real position: available && player.positionSupported ? Math.max(0, player.position) : 0
    readonly property bool canSeek: available && player.canSeek && player.positionSupported && length > 0
    function seekTo(seconds) { if (canSeek) player.position = Math.max(0, Math.min(length, seconds)) }
    function formatTime(seconds) {
        const value = Math.max(0, Math.floor(seconds))
        return Math.floor(value / 60) + ":" + String(value % 60).padStart(2, "0")
    }
    readonly property string description: artist ? artist + " · " + title : title
    function toggle() { if (player && player.canTogglePlaying) player.togglePlaying() }
    function previous() { if (player && player.canGoPrevious) player.previous() }
    function next() { if (player && player.canGoNext) player.next() }
}

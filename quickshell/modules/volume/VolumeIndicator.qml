import qs.components
import qs.services

LevelIndicator {
    available: Audio.available
    sourceIdentity: Audio.sink
    icon: Audio.muted ? "muted" : Audio.percent < 50 ? "volume-low" : "volume"
    label: Audio.muted ? "Volume · Muted" : "Volume"
    value: Audio.percent
    subdued: Audio.muted
}

import qs.components
import qs.services

LevelIndicator {
    available: Audio.inputAvailable
    sourceIdentity: Audio.source
    icon: Audio.inputMuted ? "microphone-muted" : "microphone"
    label: Audio.inputMuted ? "Microphone · Muted" : "Microphone"
    value: Audio.inputPercent
    subdued: Audio.inputMuted
}

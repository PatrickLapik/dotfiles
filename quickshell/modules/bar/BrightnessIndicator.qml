import qs.components
import qs.services

LevelIndicator {
    available: Brightness.available
    sourceIdentity: Brightness.device
    icon: "sun"
    label: "Brightness"
    value: Brightness.percent
}

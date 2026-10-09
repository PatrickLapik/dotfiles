pragma Singleton
import Quickshell
import Quickshell.Services.Pipewire
import qs.config

Singleton {
    id: root
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool available: !!sink && sink.ready && !!sink.audio
    readonly property bool muted: available && sink.audio.muted
    readonly property int percent: available ? Math.round(sink.audio.volume * 100) : 0
    readonly property string description: available ? sink.description : "No audio output"
    readonly property var outputs: Pipewire.nodes.values.filter(node =>
        node.isSink && !node.isStream && (node.type & PwNodeType.Audio))
    readonly property int outputIndex: sink ? outputs.findIndex(node => node.id === sink.id) : -1
    readonly property var outputChoices: outputs.map(node => ({ label: node.description || node.nickname || node.name }))
    readonly property var source: Pipewire.defaultAudioSource
    readonly property bool inputAvailable: !!source && source.ready && !!source.audio
    readonly property bool inputMuted: inputAvailable && source.audio.muted
    readonly property int inputPercent: inputAvailable ? Math.round(source.audio.volume * 100) : 0
    readonly property string inputDescription: inputAvailable ? source.description : "No microphone available"
    readonly property var inputs: Pipewire.nodes.values.filter(node =>
        !node.isSink && !node.isStream && (node.type & PwNodeType.Audio))
    readonly property int inputIndex: source ? inputs.findIndex(node => node.id === source.id) : -1
    readonly property var inputChoices: inputs.map(node => ({ label: node.description || node.nickname || node.name }))
    PwObjectTracker { objects: root.outputs.concat(root.inputs) }
    function selectInput(index: int) {
        const input = inputs[index]
        if (input) Pipewire.preferredDefaultAudioSource = input
    }
    function setInputPercent(value: real) {
        if (inputAvailable) source.audio.volume = Math.max(0, Math.min(1, value / 100))
    }
    function toggleInputMute() { if (inputAvailable) source.audio.muted = !source.audio.muted }
    function adjustInput(direction: int) {
        if (inputAvailable) source.audio.volume = Math.max(0, Math.min(1, source.audio.volume + direction * ShellConfig.volumeStep))
    }
    function selectOutput(index: int) {
        const output = outputs[index]
        if (output) Pipewire.preferredDefaultAudioSink = output
    }
    function setPercent(value: real) {
        if (available) sink.audio.volume = Math.max(0, Math.min(1, value / 100))
    }
    function toggleMute() { if (available) sink.audio.muted = !sink.audio.muted }
    function adjust(direction: int) {
        if (available) sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + direction * ShellConfig.volumeStep))
    }
}

pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.config

Singleton {
    id: root
    property string selectedOutputName: ""
    property string selectedInputName: ""
    property string outputError: ""
    property string inputError: ""
    property bool outputBusy: false
    property bool inputBusy: false
    readonly property string script: decodeURIComponent(Qt.resolvedUrl("../scripts/audio.py").toString().replace(/^file:\/\//, ""))
    readonly property var sink: outputs.find(node => node.name === selectedOutputName) || Pipewire.defaultAudioSink
    readonly property bool outputIsDefault: !!sink && !!Pipewire.preferredDefaultAudioSink
        && sink.name === Pipewire.preferredDefaultAudioSink.name
    readonly property bool available: !!sink && sink.ready && !!sink.audio
    readonly property bool muted: available && sink.audio.muted
    readonly property int percent: available ? Math.round(sink.audio.volume * 100) : 0
    readonly property string description: available ? sink.description : "No audio output"
    readonly property var outputs: Pipewire.nodes.values.filter(node =>
        node.isSink && !node.isStream && (node.type & PwNodeType.Audio))
    onOutputsChanged: {
        if (selectedOutputName && !outputs.some(node => node.name === selectedOutputName)) selectedOutputName = ""
    }
    readonly property int outputIndex: sink ? outputs.findIndex(node => node.id === sink.id) : -1
    readonly property var outputChoices: outputs.map(node => ({ label: node.description || node.nickname || node.name }))
    readonly property var source: inputs.find(node => node.name === selectedInputName) || Pipewire.defaultAudioSource
    readonly property bool inputIsDefault: !!source && !!Pipewire.preferredDefaultAudioSource
        && source.name === Pipewire.preferredDefaultAudioSource.name
    readonly property bool inputAvailable: !!source && source.ready && !!source.audio
    readonly property bool inputMuted: inputAvailable && source.audio.muted
    readonly property int inputPercent: inputAvailable ? Math.round(source.audio.volume * 100) : 0
    readonly property string inputDescription: inputAvailable ? source.description : "No microphone available"
    readonly property var inputs: Pipewire.nodes.values.filter(node =>
        !node.isSink && !node.isStream && (node.type & PwNodeType.Audio))
    onInputsChanged: {
        if (selectedInputName && !inputs.some(node => node.name === selectedInputName)) selectedInputName = ""
    }
    readonly property int inputIndex: source ? inputs.findIndex(node => node.id === source.id) : -1
    readonly property var inputChoices: inputs.map(node => ({ label: node.description || node.nickname || node.name }))
    PwObjectTracker { objects: root.outputs.concat(root.inputs) }
    function selectInput(index: int) {
        const input = inputs[index]
        if (input) requestInput("select", input.name)
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
        if (output) requestOutput("select", output.name)
    }
    function setOutputDefault() { if (sink) requestOutput("default", sink.name) }
    function setInputDefault() { if (source) requestInput("default", source.name) }
    function requestOutput(action: string, name: string) {
        if (outputBusy) return
        outputError = ""
        outputBusy = true
        outputWorker.result = ""
        outputWorker.command = ["python3", script, "output", action, name]
        outputWorker.running = true
    }
    function requestInput(action: string, name: string) {
        if (inputBusy) return
        inputError = ""
        inputBusy = true
        inputWorker.result = ""
        inputWorker.command = ["python3", script, "input", action, name]
        inputWorker.running = true
    }
    Process {
        id: outputWorker
        property string result: ""
        stdout: StdioCollector { onStreamFinished: outputWorker.result = text }
        stderr: StdioCollector { onStreamFinished: { if (text.trim()) root.outputError = text.trim() } }
        onExited: (code, status) => {
            if (code === 0) {
                try { root.selectedOutputName = JSON.parse(result).name }
                catch (error) { root.outputError = "Could not read the output device change." }
            } else if (!root.outputError) root.outputError = "Could not change the output device."
            root.outputBusy = false
        }
    }
    Process {
        id: inputWorker
        property string result: ""
        stdout: StdioCollector { onStreamFinished: inputWorker.result = text }
        stderr: StdioCollector { onStreamFinished: { if (text.trim()) root.inputError = text.trim() } }
        onExited: (code, status) => {
            if (code === 0) {
                try { root.selectedInputName = JSON.parse(result).name }
                catch (error) { root.inputError = "Could not read the input device change." }
            } else if (!root.inputError) root.inputError = "Could not change the input device."
            root.inputBusy = false
        }
    }
    function setPercent(value: real) {
        if (available) sink.audio.volume = Math.max(0, Math.min(1, value / 100))
    }
    function toggleMute() { if (available) sink.audio.muted = !sink.audio.muted }
    function adjust(direction: int) {
        if (available) sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + direction * ShellConfig.volumeStep))
    }
}

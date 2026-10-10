import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import qs.components
import qs.components.containers
import qs.config
import qs.services

StyledContainer {
    id: root
    required property var auth
    property string joke: LockConfig.fallbackJoke
    property url backgroundSource: ""
    readonly property real edgeInset: Math.min(Spacing.lockEdgeInset, width * 0.06)
    radius: Theme.radiusNone
    color: Colors.background
    highlightOpacity: 0

    Image {
        id: screenshot
        anchors.fill: parent
        source: root.backgroundSource
        fillMode: Image.PreserveAspectCrop
        visible: false
        asynchronous: true
        cache: false
    }
    MultiEffect {
        anchors.fill: parent
        source: screenshot
        visible: screenshot.status === Image.Ready
        blurEnabled: true
        blurMax: Sizing.lockBlurRadius
        blur: LockConfig.backgroundBlur
        autoPaddingEnabled: false
    }
    StyledContainer {
        anchors.fill: parent
        radius: Theme.radiusNone
        color: Colors.withAlpha(Colors.background, LockConfig.backgroundDim)
        highlightOpacity: 0
    }
    ColumnLayout {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: root.edgeInset
        width: Math.min(Sizing.lockJokeWidth, root.width - root.edgeInset * 2)
        spacing: Spacing.sm
        visible: root.height > Sizing.lockCompactHeight
        Text {
            text: "CHUCK NORRIS FACT"
            color: Colors.primary
            font.family: Theme.headingFontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.headingFontWeight
        }
        Text {
            Layout.fillWidth: true
            text: root.joke
            textFormat: Text.PlainText
            wrapMode: Text.WordWrap
            maximumLineCount: 5
            elide: Text.ElideRight
            color: Colors.onBackground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLarge
        }
    }
    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(Sizing.lockFormWidth, root.width - Spacing.xl * 2)
        spacing: Spacing.md
        StyledContainer {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Sizing.lockAvatarSize
            Layout.preferredHeight: Sizing.lockAvatarSize
            radius: width / 2
            color: Colors.surfaceContainer
            border.width: Theme.borderWidth
            border.color: Colors.primary
            RoundedImage {
                anchors.fill: parent
                anchors.margins: Spacing.sm
                source: "file://" + LockConfig.avatarPath
                radius: width / 2
            }
        }
        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: Quickshell.env("USER")
            textFormat: Text.PlainText
            color: Colors.onBackground
            font.family: Theme.headingFontFamily
            font.pixelSize: Theme.lockUserFontSize
            font.weight: Theme.headingFontWeight
        }
        TextField {
            id: password
            Layout.fillWidth: true
            Layout.preferredHeight: Sizing.lockInputHeight
            padding: Spacing.md
            focus: true
            enabled: !root.auth.busy
            echoMode: root.auth.responseVisible ? TextInput.Normal : TextInput.Password
            inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
            placeholderText: root.auth.responseVisible ? "Response…" : "Input password…"
            placeholderTextColor: Colors.onSurfaceVariant
            color: Colors.onSurface
            selectionColor: Colors.primary
            selectedTextColor: Colors.onPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLarge
            Accessible.name: root.auth.responseVisible ? "Authentication response" : "Password"
            background: StyledContainer {
                radius: Theme.radiusSmall
                color: Colors.surfaceContainer
                border.width: Theme.borderWidth
                border.color: root.auth.failed ? Colors.error : password.activeFocus ? Colors.primary : Colors.outline
            }
            onAccepted: root.auth.submit(text)
            onEnabledChanged: if (enabled) forceActiveFocus()
            Component.onCompleted: forceActiveFocus()
            Keys.onEscapePressed: clear()
        }
        StyledButton {
            Layout.fillWidth: true
            text: root.auth.busy ? "Checking…" : "Unlock"
            enabled: !root.auth.busy
            onClicked: root.auth.submit(password.text)
        }
        Text {
            Layout.fillWidth: true
            Layout.minimumHeight: Theme.headingLineHeight
            text: root.auth.message || (root.auth.busy ? "Authenticating…" : "Enter your password to unlock")
            textFormat: Text.PlainText
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            color: root.auth.failed ? Colors.error : Colors.onBackground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }
    ColumnLayout {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: root.edgeInset
        spacing: Spacing.xs
        visible: root.height > Sizing.lockCompactHeight
        Text {
            Layout.alignment: Qt.AlignRight
            text: Time.time
            color: Colors.onBackground
            font.family: Theme.headingFontFamily
            font.pixelSize: Theme.lockClockFontSize
            font.weight: Theme.headingFontWeight
            font.features: { "tnum": 1 }
        }
        Text {
            Layout.alignment: Qt.AlignRight
            text: Time.date
            color: Colors.onBackground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLarge
        }
    }
    Connections {
        target: root.auth
        function onClearInputs() { password.clear() }
    }
}

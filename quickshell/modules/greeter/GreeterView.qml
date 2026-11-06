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
    property url wallpaper: ""
    property string initialUser: ""
    property bool preview: true
    property real reveal: 0
    radius: Theme.radiusNone
    color: Colors.background
    highlightOpacity: 0
    GreeterAuth {
        id: auth
        preview: root.preview
        onFocusResponse: response.forceActiveFocus()
    }
    function clearStatus() {
        if (!auth.active) { auth.failed = false; auth.message = "" }
    }
    function submit() {
        auth.submit(username.text, response.text, GreeterSessions.selected)
        response.clear()
    }
    Shortcut {
        sequence: "Escape"
        onActivated: { auth.cancel(); response.clear(); username.forceActiveFocus() }
    }
    Component.onCompleted: reveal = 1
    Behavior on reveal {
        NumberAnimation { duration: Animations.enabled ? Animations.revealDuration : 0; easing.type: Animations.revealEasing }
    }
    Image {
        id: backdrop
        anchors.fill: parent
        source: root.wallpaper
        fillMode: Image.PreserveAspectCrop
    }
    MultiEffect {
        anchors.fill: parent
        source: backdrop
        visible: backdrop.status === Image.Ready
        blurEnabled: true
        blurMax: Sizing.lockBlurRadius
        blur: LockConfig.backgroundBlur
        autoPaddingEnabled: false
    }
    StyledContainer {
        anchors.fill: parent
        radius: Theme.radiusNone
        highlightOpacity: 0
        color: Colors.withAlpha(Colors.background, LockConfig.backgroundDim)
    }
    SystemClock { id: clock; precision: SystemClock.Minutes }
    ColumnLayout {
        anchors.horizontalCenter: form.horizontalCenter
        anchors.bottom: form.top
        anchors.bottomMargin: Spacing.xl
        width: form.width
        spacing: Spacing.sm
        opacity: root.reveal
        transform: Translate { y: Spacing.lg * (1 - root.reveal) }
        Text {
            Layout.fillWidth: true
            text: Qt.formatDateTime(clock.date, "HH:mm")
            horizontalAlignment: Text.AlignHCenter
            color: Colors.onBackground
            font.family: Theme.headingFontFamily
            font.pixelSize: Theme.lockClockFontSize
            font.weight: Theme.headingFontWeight
        }
        Text {
            Layout.fillWidth: true
            text: Qt.formatDateTime(clock.date, "dddd, d MMMM")
            horizontalAlignment: Text.AlignHCenter
            color: Colors.onSurfaceVariant
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLarge
        }
    }
    ColumnLayout {
        id: form
        anchors.centerIn: parent
        width: Math.min(Sizing.lockFormWidth, root.width - Spacing.xl * 2)
        spacing: Spacing.md
        opacity: root.reveal
        transform: Translate { y: Spacing.lg * (1 - root.reveal) }
        TextField {
            id: username
            Layout.fillWidth: true
            Layout.preferredHeight: Sizing.lockInputHeight
            enabled: !auth.active
            text: root.initialUser
            placeholderText: "Username"
            Accessible.name: "Username"
            padding: Spacing.md
            color: Colors.onSurface
            placeholderTextColor: Colors.onSurfaceVariant
            selectionColor: Colors.primary
            selectedTextColor: Colors.onPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLarge
            selectByMouse: true
            background: StyledContainer {
                color: Colors.surfaceContainer
                radius: Theme.radiusSmall
                border.width: Theme.borderWidth
                border.color: username.activeFocus ? Colors.primary : Colors.outlineVariant
            }
            onAccepted: response.forceActiveFocus()
            onTextEdited: root.clearStatus()
            Component.onCompleted: forceActiveFocus()
        }
        TextField {
            id: response
            Layout.fillWidth: true
            Layout.preferredHeight: Sizing.lockInputHeight
            padding: Spacing.md
            rightPadding: Sizing.lockInputHeight + Spacing.sm
            enabled: !auth.busy
            placeholderText: auth.prompt
            Accessible.name: "Password"
            echoMode: auth.echoResponse ? TextInput.Normal : TextInput.Password
            inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
            color: Colors.onSurface
            placeholderTextColor: Colors.onSurfaceVariant
            selectionColor: Colors.primary
            selectedTextColor: Colors.onPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLarge
            background: StyledContainer {
                color: Colors.surfaceContainer
                radius: Theme.radiusSmall
                border.width: Theme.borderWidth
                border.color: auth.failed ? Colors.error : response.activeFocus ? Colors.primary : Colors.outlineVariant
            }
            Keys.onEscapePressed: { response.clear(); auth.cancel() }
            onAccepted: root.submit()
            onTextEdited: root.clearStatus()
            StyledButton {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: Spacing.xs
                width: height
                flat: true
                enabled: !auth.busy
                Accessible.name: "Sign in"
                contentItem: ShellIcon { kind: "chevron-right"; tint: Colors.primary; hugContents: false }
                onClicked: root.submit()
            }
        }
    }
    Text {
        anchors.top: form.bottom
        anchors.topMargin: Spacing.md
        anchors.horizontalCenter: form.horizontalCenter
        width: form.width
        text: auth.message
        textFormat: Text.PlainText
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        color: auth.failed ? Colors.error : Colors.onSurfaceVariant
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        Accessible.role: Accessible.StaticText
    }
    RowLayout {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: Spacing.xl
        spacing: Spacing.sm
        StyledButton {
            id: restartButton
            Layout.preferredWidth: Sizing.dropdownHeight
            Layout.preferredHeight: Sizing.dropdownHeight
            Accessible.name: "Restart"
            contentItem: ShellIcon { kind: "restart"; hugContents: false }
            StyledToolTip {
                text: "Restart"
                visible: restartButton.hovered || restartButton.visualFocus
            }
            onClicked: auth.power("Restart")
        }
        StyledButton {
            id: powerButton
            Layout.preferredWidth: Sizing.dropdownHeight
            Layout.preferredHeight: Sizing.dropdownHeight
            Accessible.name: "Shutdown"
            contentItem: ShellIcon { kind: "power"; hugContents: false }
            StyledToolTip {
                text: "Shutdown"
                visible: powerButton.hovered || powerButton.visualFocus
            }
            onClicked: auth.power("Shutdown")
        }
    }
    StyledDropdown {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Spacing.xl
        width: Math.min(implicitWidth, root.width / 2 - Spacing.xl)
        model: GreeterSessions.sessions
        textRole: "name"
        currentIndex: GreeterSessions.selectedIndex
        displayText: count ? currentText : "No sessions available"
        enabled: count > 0 && !auth.active
        Accessible.name: "Desktop session"
        onActivated: index => {
            GreeterSessions.select(index)
            response.clear()
            root.clearStatus()
        }
    }
}

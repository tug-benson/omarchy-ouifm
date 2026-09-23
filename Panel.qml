pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

// Standalone floating panel (kind: "panel") — summoned via `omarchy-shell shell summon io.github.tug-benson.omarchy-ouifm '{}'`
// Shares the same Service singleton as the bar widget.

Item {
    id: root

    property string omarchyPath: ""
    property var shell: null
    property var manifest: null
    property var pluginRegistry: null

    property bool opened: false
    property bool popoutSwitchClosing: false

    readonly property var service: shell && typeof shell.serviceFor === "function"
        ? (shell.serviceFor("io.github.tug-benson.omarchy-ouifm") || shell.serviceFor("omarchy-ouifm"))
        : null

    property bool collapsed: true

    function open(payloadJson) {
        try { var p = JSON.parse(payloadJson || "{}"); } catch (e) {}
        opened = true
    }
    function close() { opened = false }
    function toggle() { opened = !opened }
    function closeForPopoutSwitch() { popoutSwitchClosing = true; opened = false; popoutSwitchClosing = false }

    IpcHandler {
        target: "io.github.tug-benson.omarchy-ouifm-panel"
        function open(payloadJson: string): string { root.open(payloadJson); return "ok" }
        function close(): string { root.close(); return "ok" }
        function toggle(payloadJson: string): string { root.toggle(); return "ok" }
        function ping(): string { return "ok" }
    }

    PanelWindow {
        id: win
        visible: root.opened
        color: "transparent"
        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        // Centered floating card
        WlrLayershell.namespace: "omarchy-ouifm"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        exclusionMode: ExclusionMode.Ignore
        mask: Region { item: card }

        // Dim background
        Rectangle {
            anchors.fill: parent
            color: Util.alpha(Color.background, 0.35)
            MouseArea {
                anchors.fill: parent
                onClicked: root.close()
            }
        }

        BorderSurface {
            id: card
            width: Math.min(parent.width - Style.space(32), Style.space(380))
            height: Math.min(parent.height - Style.space(32), flick.contentHeight + Style.space(32))
            anchors.centerIn: parent
            color: Color.background
            borderSpec: Border.surfaceSpec("popups", "border", Color.popups.border, Math.max(1, Style.space(2)))
            radius: Style.cornerRadius

            Flickable {
                id: flick
                anchors.fill: parent
                anchors.margins: Style.space(12)
                contentWidth: width
                contentHeight: col.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: col
                    width: flick.width
                    spacing: Style.space(8)

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            textFormat: Text.PlainText
                            text: "OÜI FM — La Radio du Rock"
                            font.family: Style.font.family
                            font.pixelSize: Style.font.title
                            font.bold: true
                            color: Color.foreground
                            Layout.fillWidth: true
                        }
                        Button {
                            iconText: ""
                            fontFamily: "JetBrainsMono Nerd Font"
                            fontSize: Style.font.body
                            tooltipText: "Close"
                            Layout.preferredWidth: Style.space(28)
                            onClicked: root.close()
                        }
                    }

                    OuifmContent {
                        Layout.fillWidth: true
                        service: root.service
                        collapsed: root.collapsed
                        onCollapsedChanged: root.collapsed = collapsed
                    }
                }
            }
        }
    }
}

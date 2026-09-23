pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
    id: root
    moduleName: "io.github.tug-benson.omarchy-ouifm"
    manageIpc: false

    property var hostWidget: null
    property var anchorItem: null
    property var bar: null
    property var settings: null

    readonly property var service: hostWidget && hostWidget.service
        ? hostWidget.service
        : (bar && bar.shell && typeof bar.shell.serviceFor === "function"
            ? (bar.shell.serviceFor("io.github.tug-benson.omarchy-ouifm") || bar.shell.serviceFor("omarchy-ouifm"))
            : null)

    // Keep collapsed state per-panel instance (could persist via settings later)
    property bool collapsed: true

    function open() { controller.show() }
    function close() { controller.hide() }
    function toggle() { if (opened) close(); else open() }

    function switchPanel(direction) {
        if (bar && typeof bar.switchPanelFrom === "function")
            return bar.switchPanelFrom(hostWidget || root, direction)
        return false
    }

    readonly property string fontFam: Style.font.family

    KeyboardPanel {
        id: panel
        anchorItem: root.anchorItem
        owner: root.hostWidget || root
        bar: root.bar
        open: root.opened
        focusTarget: keyCatcher
        contentWidth: Style.space(360)
        contentHeight: flick.contentHeight + Style.space(36)

        PanelKeyCatcher {
            id: keyCatcher
            anchors.fill: parent
            onCloseRequested: root.close()
            onTabRequested: function(dir) { root.switchPanel(dir) }

            Flickable {
                id: flick
                anchors.fill: parent
                contentWidth: width
                contentHeight: contentCol.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: contentCol
                    width: flick.width - Style.space(16)
                    x: Style.space(8)
                    y: Style.space(8)
                    spacing: Style.space(8)

                    OuifmContent {
                        Layout.fillWidth: true
                        service: root.service
                        collapsed: root.collapsed
                        onCollapsedChanged: root.collapsed = collapsed
                    }

                    // Footer hint
                    Text {
                        textFormat: Text.PlainText
                        Layout.fillWidth: true
                        text: "Streams via Infomaniak (MP3 128k) • Images via ouifm.fr"
                        font.family: fontFam
                        font.pixelSize: Style.font.caption - 1
                        color: Color.muted
                        opacity: 0.6
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }
}

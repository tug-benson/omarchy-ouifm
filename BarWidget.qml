pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

BarWidget {
    id: root
    moduleName: "io.github.tug-benson.omarchy-ouifm"

    readonly property var service: bar && bar.shell && typeof bar.shell.serviceFor === "function"
        ? (bar.shell.serviceFor("io.github.tug-benson.omarchy-ouifm") || bar.shell.serviceFor("omarchy-ouifm"))
        : null

    readonly property bool isPlaying: service ? service.isPlaying : false
    readonly property string currentLabel: service ? service.currentLabel : "OÜI FM"

    readonly property bool showTitleInBar: {
        if (!settings) return true
        var v = settings.showTitleInBar
        return v === undefined ? true : v !== false
    }

    function injectPanel() {
        var t = panelLoader.item
        if (!t) return
        if ("bar" in t) t.bar = root.bar
        if ("anchorItem" in t) t.anchorItem = button
        if ("hostWidget" in t) t.hostWidget = root
        if ("settings" in t) t.settings = root.settings
    }

    function togglePanel() {
        if (panelLoader.item && panelLoader.item.toggle) panelLoader.item.toggle()
    }

    readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false
    function open()  { if (panelLoader.item && panelLoader.item.open)  panelLoader.item.open() }
    function close() { if (panelLoader.item && panelLoader.item.close) panelLoader.item.close() }
    readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false
    function closeForPopoutSwitch() { if (panelLoader.item && panelLoader.item.closeForPopoutSwitch) panelLoader.item.closeForPopoutSwitch() }
    function switchPanel(direction) {
        if (panelLoader.item && panelLoader.item.switchPanel) return panelLoader.item.switchPanel(direction)
        return false
    }

    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    onBarChanged: injectPanel()
    onSettingsChanged: injectPanel()

    // ── Bar button ──
    BarIconButton {
        id: button
        anchors.fill: parent
        bar: root.bar
        // Nerd Font: 󰓃 radio, 󰐊 play, 󰏤 stop — show live state
        text: root.isPlaying ? "󰓃" : "󰓃"
        // Optional title next to icon when enabled
        tooltipText: root.isPlaying ? (root.currentLabel + " — Playing") : (root.currentLabel + " — Stopped")
        active: root.isPlaying
        onPressed: function(b) { root.togglePanel() }

        // Inline label when showTitleInBar
        // BarIconButton may not support text+icon, so we overlay a label if needed
        // Fallback: use tooltip only; bar title visible via separate widget if bar supports.
    }

    // Secondary label in bar (if bar supports text alongside icon)
    // We keep it minimal: BarIconButton tooltip shows station; actual bar text
    // could be added via bar's generic text support, but we expose via `text` property
    // For richer bar display, users can disable the icon and use the panel instead.

    Loader {
        id: panelLoader
        active: true
        source: Qt.resolvedUrl("BarPanel.qml")
        visible: false
        onLoaded: {
            root.injectPanel()
            Qt.callLater(root.injectPanel)
        }
    }
}

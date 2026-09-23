pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "visualizers/siriwave.js" as VisSiri
import "visualizers/sine.js" as VisSine
import "visualizers/plasma.js" as VisPlasma
import "visualizers/helpers.js" as H

ColumnLayout {
    id: root
    property var service: null
    property bool collapsed: true
    property string searchText: ""
    property var visBands: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    property var visPeaks: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    property var visWave: []
    property int visFrame: 0
    property var _visState: ({})
    property string _lastSpec: ""
    property string visMode: "siriwave"
    readonly property var visModes: ["siriwave", "sine", "plasma"]
    property real beatDropPulse: 0
    property real _bassAvg: 0
    property double _lastDropTime: 0

    function updateBeatDrop() {
        if (!service || !service.isPlaying || !visBands || visBands.length < 3) {
            beatDropPulse = 0
            return
        }
        var subBass = (visBands[0] + visBands[1] + visBands[2]) / 3.0
        var avg = _bassAvg * 0.85 + subBass * 0.15
        _bassAvg = avg
        var delta = subBass - avg
        var now = Date.now()
        if (subBass > 0.40 && delta > 0.15 && (now - _lastDropTime) > 260) {
            beatDropPulse = 1.0
            _lastDropTime = now
        } else {
            beatDropPulse = Math.max(0.0, beatDropPulse * 0.88 - 0.02)
        }
    }

    function updateSpectrumData(raw) {
        if (!raw) return
        if (raw === _lastSpec) return
        _lastSpec = raw
        try {
            var data = JSON.parse(raw)
            var bands = data.bands || data
            if (Array.isArray(bands) && bands.length >= 24) {
                var newBands = [], newPeaks = []
                for (var i = 0; i < 24; i++) {
                    var target = Math.min(1.0, Math.max(0.0, Number(bands[i]) || 0.0))
                    var prevPeak = visPeaks[i] || 0.0
                    newBands.push(target)
                    newPeaks.push(Math.max(target, prevPeak - 0.03))
                }
                visBands = newBands
                visPeaks = newPeaks
                visWave = Array.isArray(data.wave) ? data.wave : []
                visFrame++
                visCanvas.requestPaint()
            }
        } catch (e) {}
    }

    readonly property string fontFam: Style.font.family
    readonly property color fg: Color.foreground
    readonly property color cAccent: Color.accent
    readonly property color cMuted: Color.muted

    // Favorites + search logic
    readonly property var favStations: service ? service.favoriteStations() : []
    readonly property var filteredStations: {
        if (!service) return []
        var q = root.searchText.trim().toLowerCase()
        var all = service.stations
        var filtered = []
        for (var i = 0; i < all.length; i++) {
            var s = all[i]
            if (q === "" || s.label.toLowerCase().indexOf(q) !== -1) filtered.push(s)
        }
        // Pin favorites first, keep original order within groups
        if (!service.favorites || service.favorites.length === 0) return filtered
        var favSet = {}
        for (var f = 0; f < service.favorites.length; f++) favSet[service.favorites[f]] = true
        var favs = []
        var rest = []
        for (var j = 0; j < filtered.length; j++) {
            if (favSet[filtered[j].id]) favs.push(filtered[j]); else rest.push(filtered[j])
        }
        return favs.concat(rest)
    }

    spacing: Style.space(8)

    // ── Title ──
    RowLayout {
        Layout.fillWidth: true
        spacing: Style.space(6)
        Label {
            textFormat: Text.PlainText
            text: "󰓃"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Style.font.title + 4
            color: cAccent
        }
        Label {
            textFormat: Text.PlainText
            text: "OÜI FM"
            font.family: fontFam
            font.pixelSize: Style.font.title + 1
            font.bold: true
            color: cMuted
            Layout.fillWidth: true
        }
        Label {
            textFormat: Text.PlainText
            visible: service && service.isPlaying
            text: "● LIVE"
            font.family: fontFam
            font.pixelSize: Style.font.caption
            font.bold: true
            color: Color.urgent
        }
    }

    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Qt.rgba(1,1,1,0.08) }

    // ── Now playing card ──
    RowLayout {
        Layout.fillWidth: true
        spacing: Style.space(10)
        Rectangle {
            Layout.preferredWidth: Style.space(64)
            Layout.preferredHeight: Style.space(64)
            radius: Style.space(6)
            color: Qt.rgba(1,1,1,0.06)
            clip: true
            border.color: Qt.rgba(1,1,1,0.10)
            border.width: 1
            Label {
                anchors.centerIn: parent
                visible: cover.status !== Image.Ready
                textFormat: Text.PlainText
                text: ""
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 22
                color: cMuted
                opacity: 0.7
            }
            Image {
                id: cover
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                source: service ? ((service.trackCover && service.isPlaying ? service.trackCover : service.currentImage) || "") : ""
                asynchronous: true
                cache: true
                smooth: true
                mipmap: true
            }
            Image { visible: false; source: service ? (service.currentAltCover || "") : "" }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.space(4)
            Label {
                textFormat: Text.PlainText
                Layout.fillWidth: true
                text: service ? (service.currentLabel || "—") : "—"
                font.family: fontFam
                font.pixelSize: Style.font.subtitle
                font.bold: true
                color: fg
                elide: Text.ElideRight
            }
            Label {
                textFormat: Text.PlainText
                Layout.fillWidth: true
                visible: service && (service.trackArtist !== "" || service.trackTitle !== "" || service.nowPlaying !== "")
                text: {
                    if (!service) return ""
                    if (service.trackArtist && service.trackTitle) return service.trackArtist + " — " + service.trackTitle
                    if (service.trackTitle) return service.trackTitle
                    return service.nowPlaying
                }
                font.family: fontFam
                font.pixelSize: Style.font.body
                color: fg
                opacity: 0.85
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.Wrap
            }
            Label {
                textFormat: Text.PlainText
                Layout.fillWidth: true
                visible: !service || (service.trackArtist === "" && service.trackTitle === "" && service.nowPlaying === "")
                text: service && service.isPlaying ? "Live — Rock'n'roll" : (service && service.lastError ? service.lastError : "Select a station")
                font.family: fontFam
                font.pixelSize: Style.font.bodySmall
                color: service && service.lastError ? Color.urgent : cMuted
                elide: Text.ElideRight
            }
            RowLayout {
                spacing: Style.space(6)
                Button {
                    text: service && service.isPlaying ? "󰏤 Stop" : "󰐊 Play"
                    fontSize: Style.font.bodySmall
                    onClicked: {
                        if (!service) return
                        if (service.isPlaying) service.stop()
                        else service.play(service.currentId)
                    }
                }
                // Spotify search (sans auth) — glyph
                Button {
                    visible: service && (service.trackTitle !== "" || service.nowPlaying !== "")
                    iconText: ""
                    fontFamily: "JetBrainsMono Nerd Font"
                    fontSize: Style.font.body
                    tooltipText: "Search on Spotify"
                    Layout.preferredWidth: Style.space(28)
                    onClicked: if (service) service.searchSpotify()
                }
                // Send to Sonos — hidden if neither OmaSonos nor soco available
                Button {
                    visible: service && (service.sonosService !== null || service.hasSoco) && service.currentStream !== ""
                    iconText: "󰋊"
                    fontFamily: "JetBrainsMono Nerd Font"
                    fontSize: Style.font.body
                    tooltipText: "Send to Sonos"
                    Layout.preferredWidth: Style.space(28)
                    onClicked: if (service) service.sendToSonos()
                }
                Item { Layout.fillWidth: true }
            }
        }
    }

    // ── Volume ──
    RowLayout {
        Layout.fillWidth: true
        spacing: Style.space(8)
        Label {
            textFormat: Text.PlainText
            text: ""
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Style.font.body
            color: cMuted
        }
        Slider {
            id: volSlider
            Layout.fillWidth: true
            from: 0; to: 100; stepSize: 5
            value: service ? service.volume : 80
            onMoved: if (service) service.setVolume(value)
            onValueChanged: if (pressed && service) service.setVolume(value)
        }
        Label {
            textFormat: Text.PlainText
            text: (service ? service.volume : 80) + "%"
            font.family: fontFam
            font.pixelSize: Style.font.caption
            color: cMuted
            Layout.preferredWidth: Style.space(36)
            horizontalAlignment: Text.AlignRight
        }
    }

    // ── Visualizer (siriwave / sine / plasma) — branché sur spectrum.json réel
    Rectangle {
        id: visBox
        Layout.fillWidth: true
        implicitHeight: Style.space(52)
        radius: Style.space(4)
        color: "#06070a"
        border.color: service && service.isPlaying ? Qt.rgba(cAccent.r, cAccent.g, cAccent.b, 0.45) : Qt.rgba(1,1,1,0.12)
        border.width: 1
        clip: true

        // Mode label
        Text {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Style.space(4)
            text: (root.visMode === "siriwave" ? "Siri Wave" : root.visMode === "sine" ? "Sine Wave" : "Liquid Plasma") + " ▾"
            color: modeMouse.containsMouse ? cAccent : Qt.rgba(1,1,1,0.65)
            font.family: fontFam
            font.pixelSize: Style.font.caption * 0.85
            font.bold: true
            z: 5
            MouseArea {
                id: modeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    var idx = root.visModes.indexOf(root.visMode)
                    root.visMode = root.visModes[(idx + 1) % root.visModes.length]
                    root._visState = ({})
                    visCanvas.requestPaint()
                }
            }
        }

        Canvas {
            id: visCanvas
            anchors.fill: parent
            anchors.margins: 2
            anchors.topMargin: Style.space(12)
            onPaint: {
                var ctx = getContext("2d")
                var w = width, h = height
                ctx.clearRect(0, 0, w, h)
                root.updateBeatDrop()
                var d = {
                    bands: root.visBands,
                    wave: root.visWave,
                    frame: root.visFrame,
                    playing: service ? service.isPlaying : false,
                    width: w,
                    height: h,
                    accent: cAccent,
                    foreground: fg,
                    dim: cMuted,
                    beatDrop: root.beatDropPulse,
                    progress: 0,
                    state: root._visState
                }
                if (root.visMode === "siriwave") VisSiri.render(ctx, d)
                else if (root.visMode === "sine") VisSine.render(ctx, d)
                else if (root.visMode === "plasma") VisPlasma.render(ctx, d)
            }
        }

        MouseArea {
            anchors.fill: parent
            anchors.topMargin: Style.space(12)
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                var idx = root.visModes.indexOf(root.visMode)
                root.visMode = root.visModes[(idx + 1) % root.visModes.length]
                root._visState = ({})
                visCanvas.requestPaint()
            }
        }
    }

    // Spectrum file watcher (real FFT)
    FileView {
        id: specFile
        path: (Quickshell.env("XDG_RUNTIME_DIR") || ("/run/user/" + (Quickshell.env("UID") || "1000"))) + "/omarchy-ouifm/spectrum.json"
        watchChanges: true
        atomicWrites: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.updateSpectrumData(text())
        onLoadFailed: {}
    }

    Timer {
        id: specTimer
        interval: 66
        running: service ? service.isPlaying : false
        repeat: true
        onTriggered: {
            if (service && service.isPlaying) {
                specFile.reload()
                // fallback: if no data yet, keep previous bands and just bump frame
                root.visFrame++
                visCanvas.requestPaint()
            } else {
                // decay when paused
                var decayed = []
                var hasAny = false
                for (var k = 0; k < 24; k++) {
                    var b = Math.max(0, (root.visBands[k] || 0) * 0.82 - 0.02)
                    var p = Math.max(0, (root.visPeaks[k] || 0) * 0.82 - 0.02)
                    decayed.push(b)
                    if (b > 0) hasAny = true
                }
                root.visBands = decayed
                root.visPeaks = decayed
                if (hasAny) visCanvas.requestPaint()
            }
        }
        onRunningChanged: {
            if (!running) {
                root.visBands = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
                root.visPeaks = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
                visCanvas.requestPaint()
            } else {
                specFile.reload()
            }
        }
    }

    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Qt.rgba(1,1,1,0.08) }

    // ── Favorites zone (au dessus de la recherche) ──
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.space(4)
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.space(6)
            Label {
                textFormat: Text.PlainText
                text: "Favorites"
                font.family: fontFam
                font.pixelSize: Style.font.bodySmall
                font.bold: true
                color: fg
                opacity: 0.9
            }
            Label {
                textFormat: Text.PlainText
                text: "(" + favStations.length + ")"
                font.family: fontFam
                font.pixelSize: Style.font.caption
                color: cMuted
            }
            Item { Layout.fillWidth: true }
            Label {
                textFormat: Text.PlainText
                visible: favStations.length > 0
                text: "Starred first"
                font.family: fontFam
                font.pixelSize: Style.font.caption - 1
                color: cMuted
                opacity: 0.7
            }
        }
        // Empty placeholder
        Label {
            textFormat: Text.PlainText
            visible: favStations.length === 0
            Layout.fillWidth: true
            text: "No favorites — click star on a station to pin it"
            font.family: fontFam
            font.pixelSize: Style.font.caption
            color: cMuted
            opacity: 0.7
            wrapMode: Text.Wrap
        }
        // Favorite chips (vertical compact, max 3-4 visible without scroll)
        ColumnLayout {
            visible: favStations.length > 0
            Layout.fillWidth: true
            spacing: Style.space(4)
            Repeater {
                model: favStations
                delegate: Rectangle {
                    id: favRow
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: Style.space(36)
                    radius: Style.space(6)
                    color: service && service.currentId === modelData.id && service.isPlaying ? Util.alpha(Color.accent, 0.18) : Qt.rgba(1,1,1,0.04)
                    border.color: service && service.currentId === modelData.id ? Color.accent : Qt.rgba(1,1,1,0.08)
                    border.width: service && service.currentId === modelData.id ? 1 : 0
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Style.space(6)
                        anchors.rightMargin: Style.space(6)
                        spacing: Style.space(8)
                        Rectangle {
                            Layout.preferredWidth: Style.space(24)
                            Layout.preferredHeight: Style.space(24)
                            radius: Style.space(4)
                            clip: true
                            color: Qt.rgba(1,1,1,0.06)
                            Image {
                                anchors.fill: parent
                                source: favRow.modelData.image
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                                smooth: true
                                mipmap: true
                            }
                        }
                        Label {
                            textFormat: Text.PlainText
                            Layout.fillWidth: true
                            text: favRow.modelData.label
                            font.family: fontFam
                            font.pixelSize: Style.font.bodySmall
                            font.bold: service && service.currentId === favRow.modelData.id
                            color: service && service.currentId === favRow.modelData.id && service.isPlaying ? Color.accent : fg
                            elide: Text.ElideRight
                        }
                        // Play indicator
                        Label {
                            textFormat: Text.PlainText
                            visible: service && service.currentId === favRow.modelData.id && service.isPlaying
                            text: ""
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Style.font.caption
                            color: Color.accent
                        }
                        Button {
                            iconText: ""
                            fontFamily: "JetBrainsMono Nerd Font"
                            fontSize: Style.font.caption
                            tooltipText: "Remove from favorites"
                            Layout.preferredWidth: Style.space(24)
                            Layout.preferredHeight: Style.space(24)
                            onClicked: if (service) service.toggleFavorite(favRow.modelData.id)
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        anchors.rightMargin: Style.space(28)
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (!service) return
                            if (service.currentId === favRow.modelData.id && service.isPlaying) service.stop()
                            else service.play(favRow.modelData.id)
                        }
                    }
                }
            }
        }
    }

    // ── Search zone ──
    RowLayout {
        Layout.fillWidth: true
        spacing: Style.space(6)
        TextField {
            id: searchField
            Layout.fillWidth: true
            font.family: fontFam
            font.pixelSize: Style.font.bodySmall
            placeholderText: "Search station..."
            text: root.searchText
            onTextChanged: root.searchText = text
            leftPadding: Style.space(24)
        }
        // Search icon overlay
        Label {
            textFormat: Text.PlainText
            text: ""
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Style.font.bodySmall
            color: cMuted
            opacity: 0.7
            Layout.preferredWidth: 0
            x: searchField.x + Style.space(8)
            y: searchField.y + (searchField.height - implicitHeight) / 2
            z: 1
        }
        Button {
            visible: root.searchText.length > 0
            iconText: ""
            fontFamily: "JetBrainsMono Nerd Font"
            fontSize: Style.font.caption
            tooltipText: "Clear"
            Layout.preferredWidth: Style.space(28)
            onClicked: root.searchText = ""
        }
    }

    // ── Collapse toggle ──
    Button {
        Layout.fillWidth: true
        text: root.collapsed ? "Show stations (" + filteredStations.length + (root.searchText !== "" ? " filtered" : "") + ")" : "Hide stations"
        fontSize: Style.font.bodySmall
        onClicked: root.collapsed = !root.collapsed
    }

    // ── Station list (vertical, 3-4 lignes visibles, scrollable) ──
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.space(4)
        visible: !root.collapsed

        Label {
            textFormat: Text.PlainText
            text: filteredStations.length === 0 ? "No station found" : filteredStations.length + " station(s)" + (root.searchText !== "" ? " — filter: \"" + root.searchText + "\"" : "")
            font.family: fontFam
            font.pixelSize: Style.font.caption
            color: cMuted
            opacity: 0.8
        }

        // Scrollable viewport: 3.5 rows visible + petit extra pour ne pas tronquer la dernière ligne
        Flickable {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(filteredStations.length * (Style.space(44) + Style.space(4)), Style.space(44) * 3.5 + Style.space(16))
            clip: true
            contentWidth: width
            contentHeight: listCol.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            bottomMargin: Style.space(4)
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            ColumnLayout {
                id: listCol
                width: parent.width
                spacing: Style.space(4)

                Repeater {
                    model: filteredStations
                    delegate: Rectangle {
                        id: row
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        implicitHeight: Style.space(44)
                        radius: Style.space(6)
                        color: {
                            if (!service) return Qt.rgba(1,1,1,0.04)
                            if (service.currentId === modelData.id && service.isPlaying) return Util.alpha(Color.accent, 0.18)
                            if (mouse.containsMouse) return Qt.rgba(1,1,1,0.08)
                            return Qt.rgba(1,1,1,0.04)
                        }
                        border.color: service && service.currentId === modelData.id ? Color.accent : Qt.rgba(1,1,1,0.08)
                        border.width: service && service.currentId === modelData.id ? 1 : 0

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Style.space(6)
                            anchors.rightMargin: Style.space(6)
                            spacing: Style.space(8)

                            Rectangle {
                                Layout.preferredWidth: Style.space(32)
                                Layout.preferredHeight: Style.space(32)
                                radius: Style.space(4)
                                clip: true
                                color: Qt.rgba(1,1,1,0.06)
                                Image {
                                    anchors.fill: parent
                                    source: row.modelData.image
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: true
                                    smooth: true
                                    mipmap: true
                                }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                Label {
                                    textFormat: Text.PlainText
                                    Layout.fillWidth: true
                                    text: row.modelData.label
                                    font.family: fontFam
                                    font.pixelSize: Style.font.bodySmall
                                    font.bold: service && service.currentId === row.modelData.id
                                    color: {
                                        if (service && service.isFavorite(row.modelData.id)) return Color.accent
                                        if (service && service.currentId === row.modelData.id && service.isPlaying) return Color.accent
                                        return fg
                                    }
                                    elide: Text.ElideRight
                                }
                                Label {
                                    textFormat: Text.PlainText
                                    Layout.fillWidth: true
                                    text: service && service.currentId === row.modelData.id && service.isPlaying ? "Playing" : "MP3 128k \u2022 Infomaniak"
                                    font.family: fontFam
                                    font.pixelSize: Style.font.caption - 1
                                    color: cMuted
                                    elide: Text.ElideRight
                                }
                            }
                            Label {
                                textFormat: Text.PlainText
                                visible: service && service.currentId === row.modelData.id && service.isPlaying
                                text: ""
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: Style.font.body
                                color: Color.accent
                            }
                            // Favorite star toggle
                            Button {
                                iconText: service && service.isFavorite(row.modelData.id) ? "" : ""
                                fontFamily: "JetBrainsMono Nerd Font"
                                fontSize: Style.font.caption
                                tooltipText: service && service.isFavorite(row.modelData.id) ? "Remove from favorites" : "Add to favorites"
                                Layout.preferredWidth: Style.space(24)
                                Layout.preferredHeight: Style.space(24)
                                onClicked: if (service) service.toggleFavorite(row.modelData.id)
                            }
                        }

                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            anchors.rightMargin: Style.space(28)
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!service) return
                                if (service.currentId === row.modelData.id && service.isPlaying) service.stop()
                                else service.play(row.modelData.id)
                            }
                        }
                    }
                }
            }
        }
    }
}

pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.Commons
import qs.Ui

ColumnLayout {
    id: root
    property var service: null
    property bool collapsed: true
    property string searchText: ""
    property var visBands: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

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
                text: service && service.isPlaying ? "En direct — Rock'n'roll" : (service && service.lastError ? service.lastError : "Sélectionne une station")
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
                // Spotify search (sans auth) — glyph 
                Button {
                    visible: service && (service.trackTitle !== "" || service.nowPlaying !== "")
                    iconText: ""
                    fontFamily: "JetBrainsMono Nerd Font"
                    fontSize: Style.font.body
                    tooltipText: "Chercher sur Spotify"
                    Layout.preferredWidth: Style.space(28)
                    onClicked: if (service) service.searchSpotify()
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

    // ── Visualizer (type omaramp bars, juste sous la barre de volume) ──
    Rectangle {
        id: visBox
        visible: service && service.isPlaying
        Layout.fillWidth: true
        implicitHeight: Style.space(52)
        radius: Style.space(4)
        color: "#06070a"
        border.color: service && service.isPlaying ? Qt.rgba(cAccent.r, cAccent.g, cAccent.b, 0.45) : Qt.rgba(1,1,1,0.12)
        border.width: 1
        clip: true

        Canvas {
            id: visCanvas
            anchors.fill: parent
            anchors.margins: 2
            onPaint: {
                var ctx = getContext("2d")
                var w = width, h = height
                ctx.clearRect(0, 0, w, h)
                var bands = root.visBands
                var count = bands.length
                var gap = 3
                var barW = Math.max(2, Math.floor((w - (count - 1) * gap) / count))
                var totalW = count * barW + (count - 1) * gap
                var startX = Math.floor((w - totalW) / 2)
                var accent = cAccent
                for (var i = 0; i < count; i++) {
                    var v = Math.max(0.06, Math.min(1.0, bands[i] || 0))
                    var barH = Math.max(3, v * h * 0.92)
                    var x = startX + i * (barW + gap)
                    var y = (h - barH) / 2
                    // gradient accent → slightly darker
                    var grad = ctx.createLinearGradient(x, y, x, y + barH)
                    grad.addColorStop(0, Qt.rgba(accent.r, accent.g, accent.b, 0.95))
                    grad.addColorStop(1, Qt.rgba(accent.r * 0.6, accent.g * 0.6, accent.b * 0.6, 0.85))
                    ctx.fillStyle = grad
                    ctx.fillRect(x, y, barW, barH)
                }
            }
        }

        Timer {
            id: visTimer
            interval: 75
            running: root.service && root.service.isPlaying
            repeat: true
            onTriggered: {
                var next = []
                for (var i = 0; i < 24; i++) {
                    var prev = root.visBands[i] || 0
                    // target random 0.15–0.95, smooth toward target
                    var target = 0.15 + Math.random() * 0.80
                    // bass bump every ~8 frames
                    if (i < 4 && Math.random() < 0.18) target = 0.85 + Math.random() * 0.15
                    var v = prev * 0.55 + target * 0.45
                    // peak decay if not playing soon stoppedhandled by visible
                    next.push(Math.max(0.06, Math.min(1.0, v)))
                }
                root.visBands = next
                visCanvas.requestPaint()
            }
            onRunningChanged: if (!running) { root.visBands = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]; visCanvas.requestPaint() }
        }

        // click to toggle play/pause as shortcut
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: if (service) service.toggle()
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
                text: "★ Favoris"
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
                text: "★ = en premier"
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
            text: "Aucun favori — clique ★ sur une station pour l’épingler"
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
                        // Remove favorite
                        Button {
                            iconText: ""
                            fontFamily: "JetBrainsMono Nerd Font"
                            fontSize: Style.font.caption
                            tooltipText: "Retirer des favoris"
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
            placeholderText: "Rechercher une station…"
            text: root.searchText
            onTextChanged: root.searchText = text
            // Nerd Font search icon via placeholder not possible, use left icon overlay
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
            // Position over TextField left padding
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
            tooltipText: "Effacer"
            Layout.preferredWidth: Style.space(28)
            onClicked: root.searchText = ""
        }
    }

    // ── Collapse toggle ──
    Button {
        Layout.fillWidth: true
        text: root.collapsed ? "󰶄 Afficher les stations (" + filteredStations.length + (root.searchText !== "" ? " filtrées" : "") + ")" : "󰶂 Masquer les stations"
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
            text: filteredStations.length === 0 ? "Aucune station trouvée" : filteredStations.length + " station(s)" + (root.searchText !== "" ? " — filtre: “" + root.searchText + "”" : "")
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
                                    text: service && service.currentId === row.modelData.id && service.isPlaying ? "▶ En lecture" : "MP3 128k • Infomaniak"
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
                                tooltipText: service && service.isFavorite(row.modelData.id) ? "Retirer des favoris" : "Ajouter aux favoris"
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

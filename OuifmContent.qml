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
                source: service ? (service.currentImage || "") : ""
                asynchronous: true
                cache: true
                smooth: true
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
                visible: service && service.nowPlaying !== ""
                text: service ? service.nowPlaying : ""
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
                visible: !service || service.nowPlaying === ""
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
                Button {
                    visible: service && service.isPlaying
                    iconText: "󰝚"
                    fontFamily: "JetBrainsMono Nerd Font"
                    fontSize: Style.font.body
                    tooltipText: "Stop"
                    Layout.preferredWidth: Style.space(28)
                    onClicked: if (service) service.stop()
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

        // Scrollable viewport: 3.5 rows visible
        Flickable {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(filteredStations.length * (Style.space(44) + Style.space(4)), Style.space(44) * 3.5 + Style.space(4) * 2.5)
            clip: true
            contentWidth: width
            contentHeight: listCol.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
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

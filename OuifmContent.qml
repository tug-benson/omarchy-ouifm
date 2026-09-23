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
    property bool collapsed: false   // when true, station list is hidden

    readonly property string fontFam: Style.font.family
    readonly property color fg: Color.foreground
    readonly property color cAccent: Color.accent
    readonly property color cMuted: Color.muted

    function stationImageFor(s) {
        return s ? (s.image || "") : ""
    }

    spacing: Style.space(8)

    // ── Title ──
    RowLayout {
        Layout.fillWidth: true
        spacing: Style.space(6)
        Label {
            textFormat: Text.PlainText
            text: "󰓃" // nf-md-radio
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

    // ── Now playing card (vignette left + info right) ──
    RowLayout {
        Layout.fillWidth: true
        spacing: Style.space(10)

        // vignette / cover
        Rectangle {
            Layout.preferredWidth: Style.space(64)
            Layout.preferredHeight: Style.space(64)
            radius: Style.space(6)
            color: Qt.rgba(1,1,1,0.06)
            clip: true
            border.color: Qt.rgba(1,1,1,0.10)
            border.width: 1

            // fallback icon when no image
            Label {
                anchors.centerIn: parent
                visible: cover.status !== Image.Ready
                textFormat: Text.PlainText
                text: "" // nf-fa-music
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
            // altCover as background blur (optional, low opacity)
            Image {
                visible: false
                source: service ? (service.currentAltCover || "") : ""
            }
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
            // also on released
            onValueChanged: {
                if (pressed && service) service.setVolume(value)
            }
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

    // ── Collapse toggle ──
    Button {
        Layout.fillWidth: true
        text: root.collapsed ? "󰶄 Afficher les stations (" + (service ? service.stations.length : 0) + ")" : "󰶂 Masquer les stations"
        fontSize: Style.font.bodySmall
        onClicked: root.collapsed = !root.collapsed
    }

    // ── Station list (vertical) ──
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.space(4)
        visible: !root.collapsed

        // Header count
        Label {
            textFormat: Text.PlainText
            text: (service ? service.stations.length : 0) + " webradios disponibles"
            font.family: fontFam
            font.pixelSize: Style.font.caption
            color: cMuted
            opacity: 0.8
        }

        Repeater {
            model: service ? service.stations : []
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
                            color: service && service.currentId === row.modelData.id && service.isPlaying ? Color.accent : fg
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
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!service) return
                        // If already playing this station, stop; otherwise play
                        if (service.currentId === row.modelData.id && service.isPlaying) service.stop()
                        else service.play(row.modelData.id)
                    }
                }
            }
        }
    }
}

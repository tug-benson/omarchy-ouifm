pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string omarchyPath: ""
    property var shell: null
    property var manifest: null
    property var pluginRegistry: null

    // ── Station catalogue (infomaniak MP3 128k, stable) ──
    // id matches the LesIndesRadios vignette id, so cover URLs stay in sync
    // with https://www.ouifm.fr/
    property var stations: [
        { "id": "QnaHBfM52n", "label": "OÜI FM",                    "stream": "https://ouifm.ice.infomaniak.ch/ouifm-high.mp3",                                 "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/QnaHBfM52n/vignette_sZiQFIhpey.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/QnaHBfM52n/altCover_8CpzR8mwYE.jpeg" },
        { "id": "3qhtSltZ27", "label": "OÜI FM Classic Rock",        "stream": "https://ouifm3.ice.infomaniak.ch/ouifm3.mp3",                                      "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/3qhtSltZ27/vignette_nOidV7bBop.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/3qhtSltZ27/altCover_R7p05tD5Q2.jpeg" },
        { "id": "fkYz8mdU3T", "label": "OÜI FM Rock Indé",           "stream": "https://ouifm5.ice.infomaniak.ch/ouifm5.mp3",                                      "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/fkYz8mdU3T/vignette_cjGXBqI93r.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/fkYz8mdU3T/altCover_5NQS8PHB9b.jpeg" },
        { "id": "S2UWS5S3lJ", "label": "OÜI FM Alternatif",           "stream": "https://ouifm2.ice.infomaniak.ch/ouifm2.mp3",                                      "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/S2UWS5S3lJ/vignette_58RQVckYja.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/S2UWS5S3lJ/altCover_frjXUc4PzZ.jpeg" },
        { "id": "RFWji6sMSN", "label": "OÜI FM Top of the Week",     "stream": "https://ouifmtopoftheweek.ice.infomaniak.ch/ouifmtopweek.mp3",                     "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/RFWji6sMSN/vignette_IaflxA6D6L.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/RFWji6sMSN/altCover_zlKlXPstmF.jpeg" },
        { "id": "PVQ1nX8P2i", "label": "OÜI FM Garage Rock",         "stream": "https://ouifmgaragerock.ice.infomaniak.ch/ouifmgaragerock-128.mp3",                "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/PVQ1nX8P2i/vignette_nqZoLJ6NOr.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/PVQ1nX8P2i/altCover_ummeTyRg0j.jpeg" },
        { "id": "0hw7uCfIT8", "label": "OÜI FM Girls Rock",          "stream": "https://ouifmgirlsrock.ice.infomaniak.ch/ouifmgirlsrock.mp3",                     "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/0hw7uCfIT8/vignette_P4zb130Otm.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/0hw7uCfIT8/altCover_bmfrstgZHj.jpeg" },
        { "id": "3fkpVzB8Cc", "label": "OÜI FM Rock Français",       "stream": "https://ouifmrockfrancais.ice.infomaniak.ch/ouifmrockfrancais.mp3",               "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/3fkpVzB8Cc/vignette_lGYfIWyNKr.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/3fkpVzB8Cc/altCover_tpVSs09llO.jpeg" },
        { "id": "OSdEHZc03t", "label": "OÜI FM Blues'n'Rock",        "stream": "https://ouifmbluesnrock.ice.infomaniak.ch/ouifmbluesnrock-128.mp3",                "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/OSdEHZc03t/vignette_tLUcW39Eaj.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/OSdEHZc03t/altCover_YoCChnbflz.jpeg" },
        { "id": "tBdigJT2rb", "label": "OÜI FM Bring The Noise",     "stream": "https://ouifmbringthenoise.ice.infomaniak.ch/ouifmbringthenoise.mp3",             "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/tBdigJT2rb/vignette_HCC7xyXLiM.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/tBdigJT2rb/altCover_n2DWRpbDDN.jpeg" },
        { "id": "RN2oOuAbDH", "label": "OÜI FM Summertime",          "stream": "https://ouifmsummertime.ice.infomaniak.ch/ouifmsummertime.mp3",                   "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/RN2oOuAbDH/vignette_cMoY3n8XxW.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/RN2oOuAbDH/altCover_FmBgTWAwSs.jpeg" },
        { "id": "NSzUtv6XGF", "label": "OÜI FM Acoustic",            "stream": "https://ouifmacoustic.ice.infomaniak.ch/ouifmacoustic.mp3",                       "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/NSzUtv6XGF/vignette_Ju1TDijCWP.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/NSzUtv6XGF/altCover_5V2ADGPHxq.jpeg" },
        { "id": "xD29y7pjPX", "label": "OÜI FM Génération Woodstock","stream": "https://ouifmwoodstock.ice.infomaniak.ch/ouifmwoodstock.mp3",                     "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/xD29y7pjPX/vignette_XVoA4HcmH0.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/xD29y7pjPX/altCover_lqZekA4HEC.jpeg" },
        { "id": "QqHO8qpoE2", "label": "OÜI FM Les Slows du Rock",   "stream": "https://ouifmlesslowsdurock.ice.infomaniak.ch/ouifmslowrock.mp3",                 "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/QqHO8qpoE2/vignette_icvecoQ0B9.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/QqHO8qpoE2/altCover_PqU92eyE3T.jpeg" },
        { "id": "ufIfkfDXSl", "label": "OÜI FM Reggae",              "stream": "https://ouifmganja.ice.infomaniak.ch/ouifmganja-128.mp3",                         "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/ufIfkfDXSl/vignette_EtXn3LZ0Op.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/ufIfkfDXSl/altCover_0wys1E1Qje.jpeg" },
        { "id": "Jhdp1QoWCO", "label": "OÜI FM Rock 60's",           "stream": "https://ouifmrock60s.ice.infomaniak.ch/ouifmsixties.mp3",                         "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/Jhdp1QoWCO/vignette_OVC1nCnr2s.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/Jhdp1QoWCO/altCover_izO2zFY5Ig.jpeg" },
        { "id": "GlXr8ww38P", "label": "OÜI FM Rock 70's",           "stream": "https://ouifmrock70s.ice.infomaniak.ch/ouifmseventies.mp3",                       "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/GlXr8ww38P/vignette_xLIKxsr5Mt.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/GlXr8ww38P/altCover_K9hZYTPdEn.jpeg" },
        { "id": "6fo6l1uD2X", "label": "OÜI FM Rock 80's",           "stream": "https://ouifmrock80s.ice.infomaniak.ch/ouifmeighties.mp3",                        "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/6fo6l1uD2X/vignette_LUStwXEGji.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/6fo6l1uD2X/altCover_lT5uu98rHS.jpeg" },
        { "id": "OQiFGri4ef", "label": "OÜI FM Rock 90's",           "stream": "https://ouifmrock90s.ice.infomaniak.ch/ouifmnineties.mp3",                        "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/OQiFGri4ef/vignette_81yJ3tp7Ud.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/OQiFGri4ef/altCover_vuCbgy4duu.jpeg" },
        { "id": "PS5mho8vsS", "label": "OÜI FM Rock 2000",           "stream": "https://ouifmrock2000s.ice.infomaniak.ch/ouifmrock2000.mp3",                      "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/PS5mho8vsS/vignette_JPwFzzCtjY.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/PS5mho8vsS/altCover_v1jwed7RIJ.jpeg" },
        { "id": "AQxuZekZgM", "label": "OÜI FM Rock'n'Food",         "stream": "https://ouifmrocknfood.ice.infomaniak.ch/ouifmrocknfood.mp3",                    "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/AQxuZekZgM/vignette_4EpdkDS9n1.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/AQxuZekZgM/altCover_EJDw3dsJa1.jpeg" }
    ]

    // ── Playback state ──
    property string currentId: "QnaHBfM52n"
    property string currentStream: ""
    property string currentLabel: "OÜI FM"
    property string currentImage: ""
    property string currentAltCover: ""
    property bool isPlaying: false
    property bool isLoading: false
    property string lastError: ""
    property int volume: 80
    property string nowPlaying: ""   // ICY StreamTitle
    property string nowPlayingRaw: ""

    readonly property string ipcSocket: "/tmp/omarchy-ouifm-mpv.sock"
    readonly property var currentStation: {
        for (var i = 0; i < stations.length; i++)
            if (stations[i].id === currentId) return stations[i]
        return stations[0]
    }

    function stationById(id) {
        for (var i = 0; i < stations.length; i++)
            if (stations[i].id === id) return stations[i]
        return null
    }

    function scriptPath(name) {
        return Qt.resolvedUrl(name).toString().replace(/^file:\/\//, "")
    }

    Component.onCompleted: {
        // Resolve initial station
        var st = stationById(currentId)
        if (st) {
            currentStream = st.stream
            currentLabel = st.label
            currentImage = st.image
            currentAltCover = st.altCover
        }
        // Try to restore persisted state (volume / last station)
        restoreProc.running = true
    }

    // ── Persisted state (volume + last station) ──
    Process {
        id: restoreProc
        command: ["bash", "-lc", "cat \"$HOME/.config/omarchy-ouifm/state.json\" 2>/dev/null || echo '{}'"]
        stdout: StdioCollector { waitForEnd: true }
        onExited: function(code) {
            try {
                var o = JSON.parse(stdout.text.trim() || "{}")
                if (o.volume !== undefined) {
                    var v = Math.max(0, Math.min(100, parseInt(o.volume, 10)))
                    if (!isNaN(v)) root.volume = v
                }
                if (o.currentId) {
                    var s = root.stationById(o.currentId)
                    if (s) {
                        root.currentId = s.id
                        root.currentStream = s.stream
                        root.currentLabel = s.label
                        root.currentImage = s.image
                        root.currentAltCover = s.altCover
                    }
                }
            } catch (e) {}
        }
    }

    Process {
        id: saveProc
        stdout: StdioCollector { waitForEnd: true }
    }
    function persistState() {
        var payload = JSON.stringify({ volume: root.volume, currentId: root.currentId })
        // Escape single quotes for bash
        var esc = payload.replace(/'/g, "'\\''")
        saveProc.command = ["bash", "-lc", "mkdir -p \"$HOME/.config/omarchy-ouifm\" && printf '%s' '" + esc + "' > \"$HOME/.config/omarchy-ouifm/state.json\""]
        saveProc.running = true
    }
    onVolumeChanged: persistState()
    onCurrentIdChanged: persistState()

    // ── mpv playback ──
    Process {
        id: mpvProc
        stdout: StdioCollector { waitForEnd: false }
        stderr: StdioCollector { waitForEnd: false }
        onExited: function(code) {
            // mpv exit code 0 = clean stop; non-zero may be error
            root.isPlaying = false
            root.isLoading = false
            if (code !== 0 && code !== 1 && root.isLoading) {
                // keep lastError for UX
            }
        }
    }

    function stop() {
        if (mpvProc.running) {
            mpvProc.running = false
        }
        // Clean stray mpv instances bound to our socket
        killStaleProc.running = true
        root.isPlaying = false
        root.isLoading = false
        root.nowPlaying = ""
        root.nowPlayingRaw = ""
    }

    Process {
        id: killStaleProc
        command: ["bash", "-lc", "pkill -f 'omarchy-ouifm-mpv.sock' 2>/dev/null; rm -f /tmp/omarchy-ouifm-mpv.sock; true"]
        stdout: StdioCollector { waitForEnd: true }
    }

    function play(id) {
        var st = id ? stationById(id) : stationById(currentId)
        if (!st) return
        // If same station and already playing, toggle stop
        if (root.currentId === st.id && root.isPlaying) {
            stop()
            return
        }
        // Stop previous
        if (mpvProc.running) {
            mpvProc.running = false
        }
        // Update current immediately for UX
        root.currentId = st.id
        root.currentStream = st.stream
        root.currentLabel = st.label
        root.currentImage = st.image
        root.currentAltCover = st.altCover
        root.lastError = ""
        root.isLoading = true
        root.nowPlaying = ""

        // Ensure no stale socket, then launch
        launchAfterKill.stationStream = st.stream
        launchAfterKill.running = true
    }

    Process {
        id: launchAfterKill
        property string stationStream: ""
        command: ["bash", "-lc", "pkill -f 'omarchy-ouifm-mpv.sock' 2>/dev/null; rm -f /tmp/omarchy-ouifm-mpv.sock; sleep 0.15; true"]
        stdout: StdioCollector { waitForEnd: true }
        onExited: function(code) {
            // Launch mpv
            mpvProc.command = [
                "/usr/bin/mpv",
                "--no-video",
                "--really-quiet",
                "--no-terminal",
                "--input-ipc-server=" + root.ipcSocket,
                "--volume=" + String(root.volume),
                "--cache=yes",
                "--cache-secs=6",
                "--demuxer-max-bytes=2M",
                launchAfterKill.stationStream
            ]
            mpvProc.running = true
            root.isPlaying = true
            root.isLoading = false
            // Start metadata polling shortly after
            Qt.callLater(function() { metaTimer.restart() })
        }
    }

    function toggle() {
        if (root.isPlaying) stop()
        else play(root.currentId)
    }

    function setVolume(v) {
        var nv = Math.max(0, Math.min(100, Math.round(v)))
        root.volume = nv
        if (root.isPlaying) {
            // Try IPC first (non-blocking), fallback is next launch will use new volume
            volIpcProc.command = ["bash", "-lc", "printf '{\"command\":[\"set_property\",\"volume\"," + nv + "]}\\n' | /usr/bin/socat - UNIX-CONNECT:/tmp/omarchy-ouifm-mpv.sock 2>/dev/null || true"]
            volIpcProc.running = true
        }
    }

    Process {
        id: volIpcProc
        stdout: StdioCollector { waitForEnd: true }
    }

    // ── ICY metadata polling (StreamTitle) ──
    property string _metaUrl: ""
    Timer {
        id: metaTimer
        interval: 7000
        repeat: true
        running: root.isPlaying
        onTriggered: {
            if (!root.currentStream) return
            // Query Icecast status via Icy-MetaData header trick: use curl with header
            // Infomaniak exposes icy metadata inline; mpv also prints it but we poll via curl
            metaProc.command = ["bash", "-lc", "curl -s -m 4 -H \"Icy-MetaData:1\" -H \"User-Agent: omarchy-ouifm/1.0\" \"" + root.currentStream + "\" -o /dev/null -D - 2>/dev/null | tr -d '\\r' | grep -i '^icy-' || curl -s -m 4 \"" + root.currentStream.replace("https://", "https://") + "\" -I 2>/dev/null | tr -d '\\r' | grep -i '^icy-' ; true"]
            metaProc.running = true
        }
        onRunningChanged: if (!running) { root.nowPlaying = ""; }
    }

    Process {
        id: metaProc
        stdout: StdioCollector { waitForEnd: true }
        onExited: function(code) {
            var txt = stdout.text || ""
            // Try to extract StreamTitle from icy headers or fallback to parsing
            // Infomaniak sends icy-name/br but not always StreamTitle; we try alternative endpoint
            if (txt.indexOf("StreamTitle") !== -1) {
                var m = txt.match(/StreamTitle='([^']*)'/)
                if (m && m[1]) {
                    root.nowPlayingRaw = m[1]
                    root.nowPlaying = m[1].trim()
                    return
                }
            }
            // Fallback: try to fetch via mpv IPC property (media-title)
            titleIpcProc.command = ["bash", "-lc", "printf '{\"command\":[\"get_property\",\"media-title\"]}\\n' | socat - UNIX-CONNECT:/tmp/omarchy-ouifm-mpv.sock 2>/dev/null | python3 -c \"import sys,json; d=json.load(sys.stdin) if sys.stdin.read().strip() else {}; print(d.get('data',''))\" 2>/dev/null; true"]
            titleIpcProc.running = true
        }
    }

    Process {
        id: titleIpcProc
        stdout: StdioCollector { waitForEnd: true }
        onExited: function(code) {
            var t = (stdout.text || "").trim()
            if (t && t !== "" && t !== "null") {
                // Filter out raw URL as title
                if (t.indexOf("http") !== 0) {
                    root.nowPlaying = t
                    root.nowPlayingRaw = t
                }
            }
        }
    }

    // ── External control via IPC ──
    IpcHandler {
        target: "io.github.tug-benson.omarchy-ouifm"
        function play(id: string): string { root.play(id); return "ok" }
        function stop(): string { root.stop(); return "ok" }
        function toggle(): string { root.toggle(); return "ok" }
        function setVolume(v: string): string { root.setVolume(parseInt(v, 10)); return "ok" }
        function ping(): string { return "ok" }
    }
}

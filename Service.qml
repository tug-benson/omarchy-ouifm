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
        { "id": "QnaHBfM52n", "idMds": "2174546520932614531", "label": "OÜI FM",                    "stream": "https://ouifm.ice.infomaniak.ch/ouifm-high.mp3",                                 "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/QnaHBfM52n/vignette_sZiQFIhpey.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/QnaHBfM52n/altCover_8CpzR8mwYE.jpeg" },
        { "id": "3qhtSltZ27", "idMds": "3134161803443976427", "label": "OÜI FM Classic Rock",        "stream": "https://ouifm3.ice.infomaniak.ch/ouifm3.mp3",                                      "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/3qhtSltZ27/vignette_nOidV7bBop.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/3qhtSltZ27/altCover_R7p05tD5Q2.jpeg" },
        { "id": "fkYz8mdU3T", "idMds": "3134161803443976526", "label": "OÜI FM Rock Indé",           "stream": "https://ouifm5.ice.infomaniak.ch/ouifm5.mp3",                                      "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/fkYz8mdU3T/vignette_cjGXBqI93r.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/fkYz8mdU3T/altCover_5NQS8PHB9b.jpeg" },
        { "id": "S2UWS5S3lJ", "idMds": "3134161803443976382", "label": "OÜI FM Alternatif",           "stream": "https://ouifm2.ice.infomaniak.ch/ouifm2.mp3",                                      "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/S2UWS5S3lJ/vignette_58RQVckYja.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/S2UWS5S3lJ/altCover_frjXUc4PzZ.jpeg" },
        { "id": "RFWji6sMSN", "idMds": "3754485939764896014", "label": "OÜI FM Top of the Week",     "stream": "https://ouifmtopoftheweek.ice.infomaniak.ch/ouifmtopweek.mp3",                     "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/RFWji6sMSN/vignette_IaflxA6D6L.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/RFWji6sMSN/altCover_zlKlXPstmF.jpeg" },
        { "id": "PVQ1nX8P2i", "idMds": "1016696403088961793", "label": "OÜI FM Garage Rock",         "stream": "https://ouifmgaragerock.ice.infomaniak.ch/ouifmgaragerock-128.mp3",                "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/PVQ1nX8P2i/vignette_nqZoLJ6NOr.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/PVQ1nX8P2i/altCover_ummeTyRg0j.jpeg" },
        { "id": "0hw7uCfIT8", "idMds": "3864441174941011218", "label": "OÜI FM Girls Rock",          "stream": "https://ouifmgirlsrock.ice.infomaniak.ch/ouifmgirlsrock.mp3",                     "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/0hw7uCfIT8/vignette_P4zb130Otm.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/0hw7uCfIT8/altCover_bmfrstgZHj.jpeg" },
        { "id": "3fkpVzB8Cc", "idMds": "3820775684199026845", "label": "OÜI FM Rock Français",       "stream": "https://ouifmrockfrancais.ice.infomaniak.ch/ouifmrockfrancais.mp3",               "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/3fkpVzB8Cc/vignette_lGYfIWyNKr.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/3fkpVzB8Cc/altCover_tpVSs09llO.jpeg" },
        { "id": "OSdEHZc03t", "idMds": "3134161803443976485", "label": "OÜI FM Blues'n'Rock",        "stream": "https://ouifmbluesnrock.ice.infomaniak.ch/ouifmbluesnrock-128.mp3",                "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/OSdEHZc03t/vignette_tLUcW39Eaj.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/OSdEHZc03t/altCover_YoCChnbflz.jpeg" },
        { "id": "tBdigJT2rb", "idMds": "4004502594738215513", "label": "OÜI FM Bring The Noise",     "stream": "https://ouifmbringthenoise.ice.infomaniak.ch/ouifmbringthenoise.mp3",             "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/tBdigJT2rb/vignette_HCC7xyXLiM.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/tBdigJT2rb/altCover_n2DWRpbDDN.jpeg" },
        { "id": "RN2oOuAbDH", "idMds": "3652031559378160590", "label": "OÜI FM Summertime",          "stream": "https://ouifmsummertime.ice.infomaniak.ch/ouifmsummertime.mp3",                   "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/RN2oOuAbDH/vignette_cMoY3n8XxW.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/RN2oOuAbDH/altCover_FmBgTWAwSs.jpeg" },
        { "id": "NSzUtv6XGF", "idMds": "3906034555622012146", "label": "OÜI FM Acoustic",            "stream": "https://ouifmacoustic.ice.infomaniak.ch/ouifmacoustic.mp3",                       "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/NSzUtv6XGF/vignette_Ju1TDijCWP.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/NSzUtv6XGF/altCover_5V2ADGPHxq.jpeg" },
        { "id": "xD29y7pjPX", "idMds": "3707948669989820452", "label": "OÜI FM Génération Woodstock","stream": "https://ouifmwoodstock.ice.infomaniak.ch/ouifmwoodstock.mp3",                     "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/xD29y7pjPX/vignette_XVoA4HcmH0.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/xD29y7pjPX/altCover_lqZekA4HEC.jpeg" },
        { "id": "QqHO8qpoE2", "idMds": "3818508936105954443", "label": "OÜI FM Les Slows du Rock",   "stream": "https://ouifmlesslowsdurock.ice.infomaniak.ch/ouifmslowrock.mp3",                 "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/QqHO8qpoE2/vignette_icvecoQ0B9.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/QqHO8qpoE2/altCover_PqU92eyE3T.jpeg" },
        { "id": "ufIfkfDXSl", "idMds": "3540892623380233022", "label": "OÜI FM Reggae",              "stream": "https://ouifmganja.ice.infomaniak.ch/ouifmganja-128.mp3",                         "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/ufIfkfDXSl/vignette_EtXn3LZ0Op.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/ufIfkfDXSl/altCover_0wys1E1Qje.jpeg" },
        { "id": "Jhdp1QoWCO", "idMds": "3540892623380233039", "label": "OÜI FM Rock 60's",           "stream": "https://ouifmrock60s.ice.infomaniak.ch/ouifmsixties.mp3",                         "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/Jhdp1QoWCO/vignette_OVC1nCnr2s.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/Jhdp1QoWCO/altCover_izO2zFY5Ig.jpeg" },
        { "id": "GlXr8ww38P", "idMds": "3540892623380233057", "label": "OÜI FM Rock 70's",           "stream": "https://ouifmrock70s.ice.infomaniak.ch/ouifmseventies.mp3",                       "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/GlXr8ww38P/vignette_xLIKxsr5Mt.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/GlXr8ww38P/altCover_K9hZYTPdEn.jpeg" },
        { "id": "6fo6l1uD2X", "idMds": "3610476513821993259", "label": "OÜI FM Rock 80's",           "stream": "https://ouifmrock80s.ice.infomaniak.ch/ouifmeighties.mp3",                        "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/6fo6l1uD2X/vignette_LUStwXEGji.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/6fo6l1uD2X/altCover_lT5uu98rHS.jpeg" },
        { "id": "OQiFGri4ef", "idMds": "3610476513821993340", "label": "OÜI FM Rock 90's",           "stream": "https://ouifmrock90s.ice.infomaniak.ch/ouifmnineties.mp3",                        "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/OQiFGri4ef/vignette_81yJ3tp7Ud.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/OQiFGri4ef/altCover_vuCbgy4duu.jpeg" },
        { "id": "PS5mho8vsS", "idMds": "3652031559378160547", "label": "OÜI FM Rock 2000",           "stream": "https://ouifmrock2000s.ice.infomaniak.ch/ouifmrock2000.mp3",                      "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/PS5mho8vsS/vignette_JPwFzzCtjY.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/PS5mho8vsS/altCover_v1jwed7RIJ.jpeg" },
        { "id": "AQxuZekZgM", "idMds": "3796007387461058949", "label": "OÜI FM Rock'n'Food",         "stream": "https://ouifmrocknfood.ice.infomaniak.ch/ouifmrocknfood.mp3",                    "image": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/AQxuZekZgM/vignette_4EpdkDS9n1.jpeg", "altCover": "https://bocir-medias-prod.s3.fr-par.scw.cloud/radios/ouifm/radiostream/AQxuZekZgM/altCover_EJDw3dsJa1.jpeg" }
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
    property string nowPlaying: ""   // "Artist — Title" from TitleDiffusions
    property string nowPlayingRaw: ""
    property string trackArtist: ""
    property string trackTitle: ""
    property string trackCover: ""
    property string trackTimestamp: ""
    property string currentMdsId: ""
    property var favorites: []   // array of station ids
    readonly property var sonosService: shell && shell.serviceFor ? shell.serviceFor("io.github.ctl0v0.omasonos") : null
    property bool hasSoco: false

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

    function isFavorite(id) {
        return favorites.indexOf(id) !== -1
    }
    function toggleFavorite(id) {
        var idx = favorites.indexOf(id)
        var next = favorites.slice()
        if (idx === -1) next.push(id)
        else next.splice(idx, 1)
        favorites = next
    }
    function favoriteStations() {
        var out = []
        for (var i = 0; i < favorites.length; i++) {
            var s = stationById(favorites[i])
            if (s) out.push(s)
        }
        return out
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
            currentMdsId = st.idMds || ""
        }
        restoreProc.running = true
        hasSocoProc.running = true
    }

    Process {
        id: hasSocoProc
        command: ["bash", "-lc", "python3 -c 'import soco' 2>/dev/null && echo 1 || (~/.local/share/io.github.ctl0v0.omasonos/venv/bin/python -c 'import soco' 2>/dev/null && echo 1) || echo 0"]
        stdout: StdioCollector { waitForEnd: true }
        onExited: function(code) { hasSoco = (stdout.text.trim() === "1") }
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
                        root.currentMdsId = s.idMds || ""
                    }
                }
                if (o.favorites && Array.isArray(o.favorites)) {
                    // Sanitize: keep only known ids
                    var clean = []
                    for (var i = 0; i < o.favorites.length; i++)
                        if (root.stationById(o.favorites[i])) clean.push(o.favorites[i])
                    root.favorites = clean
                }
            } catch (e) {}
        }
    }

    Process {
        id: saveProc
        stdout: StdioCollector { waitForEnd: true }
    }
    function persistState() {
        var payload = JSON.stringify({ volume: root.volume, currentId: root.currentId, favorites: root.favorites })
        // Escape single quotes for bash
        var esc = payload.replace(/'/g, "'\\''")
        saveProc.command = ["bash", "-lc", "mkdir -p \"$HOME/.config/omarchy-ouifm\" && printf '%s' '" + esc + "' > \"$HOME/.config/omarchy-ouifm/state.json\""]
        saveProc.running = true
    }
    onVolumeChanged: persistState()
    onCurrentIdChanged: persistState()
    onFavoritesChanged: persistState()

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
        killStaleProc.running = true
        stopSpectrum()
        root.isPlaying = false
        root.isLoading = false
        root.nowPlaying = ""
        root.nowPlayingRaw = ""
        root.trackArtist = ""
        root.trackTitle = ""
        root.trackCover = ""
        root.trackTimestamp = ""
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
        root.currentMdsId = st.idMds || ""
        root.lastError = ""
        root.isLoading = true
        root.nowPlaying = ""
        root.trackArtist = ""
        root.trackTitle = ""
        root.trackCover = ""
        root.trackTimestamp = ""

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
            // Start metadata + spectrum
            Qt.callLater(function() { metaTimer.restart(); startSpectrum() })
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

    // ── Track metadata via ouifm.fr TitleDiffusions (primary) + mpv fallback
    // Bounded: 6s timeout + 8 KiB cap + Python 8 KiB read + 100 char truncation per field
    Timer {
        id: metaTimer
        interval: 15000
        repeat: true
        running: root.isPlaying
        triggeredOnStart: true
        onTriggered: {
            if (!root.currentMdsId) return
            var ts = Date.now()
            titleProc.command = ["bash", "-lc", "curl -s -m 6 \"https://www.ouifm.fr/api/TitleDiffusions?size=1&radioStreamId=" + root.currentMdsId + "&date=" + ts + "\" -H \"Referer: https://www.ouifm.fr/\" -H \"User-Agent: Mozilla/5.0\" 2>/dev/null | head -c 8192 | python3 -c \"import sys,json; s=sys.stdin.read(8192).strip(); d=json.loads(s) if s else []; t=d[0].get('title',{}) if d and len(d)>0 else {}; print(((t.get('artist') or '')[:100] + '|' + (t.get('title') or '')[:100] + '|' + (t.get('coverUrl') or '')[:512]))\" 2>/dev/null; true"]
            titleProc.running = true
        }
        onRunningChanged: {
            if (!running) {
                root.nowPlaying = ""
                root.trackArtist = ""
                root.trackTitle = ""
                root.trackCover = ""
                root.trackTimestamp = ""
            }
        }
    }

    Process {
        id: titleProc
        stdout: StdioCollector { waitForEnd: true }
        // Bounded stdout: StdioCollector default is 1 MiB, but we also cap via head/python
        onExited: function(code) {
            var txt = (stdout.text || "").trim().substring(0, 800)
            if (txt && txt.indexOf("|") !== -1) {
                var parts = txt.split("|")
                var artist = (parts[0] || "").trim().substring(0, 100)
                var title = (parts[1] || "").trim().substring(0, 100)
                var cover = (parts[2] || "").trim().substring(0, 512)
                if (artist !== "" || title !== "") {
                    root.trackArtist = artist
                    root.trackTitle = title
                    root.trackCover = cover
                    root.trackTimestamp = new Date().toISOString()
                    var combined = artist && title ? artist + " — " + title : (artist || title)
                    combined = combined.substring(0, 210)
                    root.nowPlaying = combined
                    root.nowPlayingRaw = combined
                    return
                }
            }
            // Fallback to mpv media-title if API empty
            titleIpcProc.command = ["bash", "-lc", "printf '{\"command\":[\"get_property\",\"media-title\"]}\\n' | /usr/bin/socat - UNIX-CONNECT:/tmp/omarchy-ouifm-mpv.sock 2>/dev/null | head -c 4096 | python3 -c \"import sys,json; s=sys.stdin.read(4096).strip(); d=json.loads(s) if s else {}; print(str(d.get('data',''))[:200])\" 2>/dev/null; true"]
            titleIpcProc.running = true
        }
    }

    Process {
        id: titleIpcProc
        stdout: StdioCollector { waitForEnd: true }
        onExited: function(code) {
            var t = (stdout.text || "").trim().substring(0, 200)
            if (t && t !== "" && t !== "null" && t.indexOf("http") !== 0) {
                t = t.substring(0, 200)
                root.nowPlaying = t
                root.nowPlayingRaw = t
                root.trackTitle = t
                root.trackArtist = ""
            }
        }
    }

    function searchSpotify() {
        var q = ""
        if (trackArtist && trackTitle) q = trackArtist + " - " + trackTitle
        else if (trackTitle) q = trackTitle
        else if (nowPlaying) q = nowPlaying
        else if (currentLabel) q = currentLabel
        else return
        // Encode for URL, open in browser without auth
        var url = "https://open.spotify.com/search/" + encodeURIComponent(q)
        spotifyProc.command = ["bash", "-lc", "xdg-open \"" + url.replace(/\"/g, "\\\"") + "\" 2>/dev/null || gio open \"" + url.replace(/\"/g, "\\\"") + "\" 2>/dev/null || true"]
        spotifyProc.running = true
    }

    Process {
        id: spotifyProc
        stdout: StdioCollector { waitForEnd: true }
    }

    function normalizeForSonos(s) {
        var t = String(s || "").toLowerCase()
        // strip accents for ouï -> oui
        t = t.replace(/ï/g, "i").replace(/ù/g, "u").replace(/é/g, "e").replace(/è/g, "e")
        return t.trim()
    }
    function sendToSonos() {
        if (!currentStream && !currentLabel) return
        // 1. Try OmaSonos favorites (TuneIn) — user has OUI FM webradios as Sonos favorites
        try {
            var svc = sonosService
            if (svc && svc.snapshot && svc.snapshot.favorites && svc.snapshot.favorites.items) {
                var items = svc.snapshot.favorites.items
                var curNorm = normalizeForSonos(currentLabel)
                var curSuffix = curNorm.replace(/^oui fm\s*/,"").trim()
                var best = null
                var bestScore = -1
                for (var i = 0; i < items.length; i++) {
                    var fav = items[i]
                    var title = String(fav.title || "")
                    var tNorm = normalizeForSonos(title)
                    var score = -1
                    if (tNorm === curNorm) score = 100
                    else if (curNorm && tNorm.indexOf(curNorm) !== -1) score = 80
                    else if (curNorm && curNorm.indexOf(tNorm) !== -1) score = 80
                    else if (curSuffix && tNorm.indexOf(curSuffix) !== -1) score = 60
                    else if (curSuffix && curSuffix.indexOf(tNorm) !== -1) score = 50
                    // also try matching without "oui fm" prefix for webradios like "Classic Rock"
                    if (score > bestScore) { bestScore = score; best = fav }
                }
                if (best && bestScore >= 50 && typeof svc.playFavorite === "function") {
                    console.log("ouifm: Sonos via OmaSonos favorite", best.title, best.id, "score", bestScore)
                    svc.playFavorite(best.id, best.title)
                    return
                } else if (best) {
                    console.log("ouifm: Sonos favorite bestScore too low", best.title, bestScore, "cur", curNorm)
                } else {
                    console.log("ouifm: Sonos no favorite match for", curNorm, "items", items.length)
                }
                // No good match: if OmaSonos is ready but no favorite, still fallback to direct
                // Also trigger refresh if favorites not loaded
                if (svc.snapshot.favorites.state === "not_loaded" && typeof svc.refreshFavorites === "function") {
                    svc.refreshFavorites()
                }
            }
        } catch (e) {
            console.warn("OmaSonos favorite lookup failed", e)
        }
        // 2. Fallback: direct play_uri via soco (with hint IP from OmaSonos)
        var title = currentLabel || "OUI FM"
        var hintIp = ""
        try {
            var svc2 = sonosService
            console.log("ouifm: Sonos svc", svc2 ? "found" : "null", "snapshot", svc2 && svc2.snapshot ? svc2.snapshot.status.state : "none")
            if (svc2 && svc2.snapshot) {
                if (svc2.snapshot.target && svc2.snapshot.target.ip) hintIp = String(svc2.snapshot.target.ip)
                else if (svc2.snapshot.households && svc2.snapshot.households.length > 0) {
                    var hh = svc2.snapshot.households[0]
                    if (hh.rooms && hh.rooms.length > 0) hintIp = String(hh.rooms[0].ip || "")
                }
                console.log("ouifm: Sonos hintIp", hintIp)
            }
        } catch (e) { console.warn("ouifm: Sonos hintIp error", e) }
        var script = Qt.resolvedUrl("bin/omarchy-ouifm-sonos").toString().replace(/^file:\/\//, "")
        // Use bash wrapper so helper re-exec works reliably from QML Process
        var escUri = currentStream.replace(/'/g, "'\\''")
        var escTitle = title.replace(/'/g, "'\\''")
        var escHint = hintIp.replace(/'/g, "'\\''")
        var cmd = "'" + script.replace(/'/g, "'\\''") + "' '" + escUri + "' '" + escTitle + "'"
        if (hintIp) cmd += " '" + escHint + "'"
        console.log("ouifm: Sonos fallback exec", cmd)
        sonosProc.command = ["bash", "-lc", cmd + " 2>&1; echo EXIT:$?"]
        sonosProc.running = true
    }
    Process {
        id: sonosProc
        stdout: StdioCollector { waitForEnd: true }
        stderr: StdioCollector { waitForEnd: true }
        onExited: function(code) {
            if (code !== 0) console.warn("Sonos send failed, code", code, stdout.text, stderr.text)
        }
    }

    // ── Spectrum daemon (real FFT via parec/pw-record) ──
    property bool spectrumRunning: false
    Process {
        id: spectrumProc
        stdout: StdioCollector { waitForEnd: true }
        stderr: StdioCollector { waitForEnd: true }
    }
    function startSpectrum() {
        if (spectrumProc.running) return
        var script = Qt.resolvedUrl("spectrum.py").toString().replace(/^file:\/\//, "")
        spectrumProc.command = ["python3", script]
        spectrumProc.running = true
        spectrumRunning = true
    }
    function stopSpectrum() {
        if (spectrumProc.running) spectrumProc.running = false
        spectrumRunning = false
        // kill any orphan python spectrum.py
        killSpectrumProc.running = true
    }
    Process {
        id: killSpectrumProc
        command: ["bash", "-lc", "pkill -f 'omarchy-ouifm.*spectrum.py' 2>/dev/null; rm -f /run/user/$(id -u)/omarchy-ouifm/spectrum.json 2>/dev/null; true"]
        stdout: StdioCollector { waitForEnd: true }
    }

    // ── External control via IPC ──
    IpcHandler {
        target: "io.github.tug-benson.omarchy-ouifm"
        function play(id: string): string { root.play(id); return "ok" }
        function stop(dummy: string): string { root.stop(); return "ok" }
        function toggle(dummy: string): string { root.toggle(); return "ok" }
        function setVolume(v: string): string { root.setVolume(parseInt(v, 10)); return "ok" }
        function toggleFavorite(id: string): string { root.toggleFavorite(id); return "ok" }
        function searchSpotify(dummy: string): string { root.searchSpotify(); return "ok" }
        function sendToSonos(dummy: string): string { root.sendToSonos(); return "ok" }
        function ping(dummy: string): string { return "ok" }
    }
}

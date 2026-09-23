# OUI FM for Omarchy

An [Omarchy](https://omarchy.org) plugin to listen to **OÜI FM** and its 20 webradios directly from the desktop.

![OUI FM panel](preview.png)

## Features

- **21 stations** — OÜI FM (national) + 20 webradios: Classic Rock, Rock Indé, Alternatif, Top of the Week, Garage Rock, Girls Rock, Rock Français, Blues'n'Rock, Bring The Noise, Acoustic, Génération Woodstock, Les Slows du Rock, Reggae, Rock 60's / 70's / 80's / 90's / 2000, Summertime, Rock'n'Food. See [ouifm.fr](https://www.ouifm.fr/).
- **Bar widget + floating panel** — `bar-widget` shows a radio icon (● LIVE when playing); click to open a panel with the current station. `panel` can also be summoned as a floating window.
- **Now playing card** — title at the top, cover/vignette on the left and live info on the right (station name + StreamTitle when available).
- **Collapsible vertical list** — tap *Afficher les stations* to reveal all webradios in a vertical list with their vignettes. The current station is highlighted with an accent border.
- **mpv playback** — streams are played via `mpv` (`--no-video --input-ipc-server`) against stable `ice.infomaniak.ch` MP3 128k endpoints (no expiring tokens, no scraping at runtime).
- **Volume + persistence** — volume slider (IPC via `socat`, fallback to mpv `--volume` on next play) and last station are persisted to `~/.config/omarchy-ouifm/state.json`.

## Installation

```bash
omarchy plugin add https://github.com/tug-benson/omarchy-ouifm --enable
```

Or symlink during development:

```bash
ln -s /path/to/omarchy-ouifm ~/.config/omarchy/plugins/io.github.tug-benson.omarchy-ouifm
omarchy-shell shell rescanPlugins
```

To remove:

```bash
omarchy plugin remove io.github.tug-benson.omarchy-ouifm
```

## Dependencies

```bash
sudo pacman -S mpv socat curl
```

- `mpv` — audio playback (no video, IPC for volume).
- `socat` — send JSON IPC to mpv (`/tmp/omarchy-ouifm-mpv.sock`). Without it, volume still applies on the next play.
- `curl` — ICY metadata polling for StreamTitle.
- `python3` — optional, used to parse mpv `media-title` JSON.

All streams are public MP3 128k at `*.ice.infomaniak.ch`; cover art comes from `bocir-medias-prod.s3.fr-par.scw.cloud` (the vignettes used on ouifm.fr).

## Usage

1. Click the radio icon in the bar to open the panel (or run `omarchy-shell shell summon io.github.tug-benson.omarchy-ouifm '{}'`).
2. The top card shows the current station cover and status. **Play/Stop** and the **volume slider** are there.
3. Click *Afficher les stations (21)* to expand the list, then click a row to play it. Clicking the currently-playing row stops it.
4. Close with `Esc` or the `` button.

The `panel` kind can also be used as a standalone floating window without the bar widget.

## How it works

- `Service.qml` holds the station catalogue (`id`/`label`/`stream`/`image`/`altCover`), starts `mpv --input-ipc-server=/tmp/omarchy-ouifm-mpv.sock`, and exposes `play(id)`, `stop()`, `toggle()`, `setVolume(v)`. State is persisted to `~/.config/omarchy-ouifm/state.json`.
- `BarWidget.qml` + `BarPanel.qml` — bar icon + `KeyboardPanel` popover anchored to the bar button.
- `Panel.qml` — floating `PanelWindow` (same `OuifmContent.qml` inside) for `kind: "panel"`.
- `OuifmContent.qml` — shared layout: title, now-playing card, volume, collapsible vertical list.

No secrets are stored. No privileged operations.

## Layout

```
omarchy-ouifm/
├── manifest.json
├── Service.qml          # station catalogue, mpv lifecycle, state persistence
├── BarWidget.qml        # bar icon + Loader -> BarPanel
├── BarPanel.qml         # KeyboardPanel anchored to bar button
├── Panel.qml            # floating PanelWindow (panel kind)
├── OuifmContent.qml     # shared UI (title, now playing, volume, station list)
├── README.md
├── LICENSE
└── preview.png
```

## License

MIT — see [LICENSE](LICENSE).

# PomoTimer

A small native macOS Pomodoro timer. Lives in a window, a menu bar item, or just the menu bar — your choice.

> _Screenshot — coming soon._

## Features

- 25 / 5 / 15 minute work / short break / long break, all configurable
- Long break automatically every N pomodoros (default 4)
- Phase-specific system sounds + Dock-icon bounce on every transition
- "Completed today" counter that survives app restarts and resets at local midnight
- Menu-bar item with live countdown
- Optional menu-bar-only mode — no Dock icon, no Cmd+Tab entry
- Settings persisted in `UserDefaults`

## Requirements

- macOS 14 (Sonoma) or newer
- Xcode Command Line Tools (only for building from source)

## Install

### Option A — download a pre-built `.app`

_Coming with the first tagged release._

### Option B — build from source

```bash
git clone https://github.com/<your-user>/pomotimer
cd pomotimer
./make-app.sh
open dist/PomoTimer.app
```

`make-app.sh` does a release `swift build`, generates the icon, and assembles the bundle under `dist/`.

## Gatekeeper note

The binary is **not code-signed**. If you download the app (rather than build it locally), macOS will refuse to open it on first launch with a warning like _"PomoTimer.app can't be opened because Apple cannot check it for malicious software."_

To bypass that one time:

1. Right-click `PomoTimer.app` → **Open**
2. Click **Open** in the dialog

Or remove the quarantine attribute from the terminal:

```bash
xattr -d com.apple.quarantine /path/to/PomoTimer.app
```

## Development

```bash
swift run     # build + launch unbundled executable
swift build   # build only
```

Open `Package.swift` in Xcode for a normal IDE workflow.

## License

[MIT](LICENSE) — Copyright (c) 2026 off1ine

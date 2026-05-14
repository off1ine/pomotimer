#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

APP="dist/PomoTimer.app"
BIN_NAME="PomoTimer"

echo "==> Building release binary"
swift build -c release

echo "==> Generating app icon"
swift tools/generate_icon.swift

echo "==> Assembling $APP"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp ".build/release/$BIN_NAME" "$APP/Contents/MacOS/$BIN_NAME"
cp "build/AppIcon.icns"       "$APP/Contents/Resources/AppIcon.icns"
cp "Resources/Info.plist"     "$APP/Contents/Info.plist"

# Stamp a PkgInfo (Apple's old-school four-cc bundle marker — harmless and traditional)
printf 'APPL????' > "$APP/Contents/PkgInfo"

echo "==> Done: $APP"
echo "    open $APP   # to launch"

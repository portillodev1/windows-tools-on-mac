#!/usr/bin/env bash
# Monta build/WinTools.app a partir do binário SwiftPM + Support/Info.plist e assina.
# Uso: scripts/bundle.sh [--debug]
# Assinatura: ad-hoc por padrão. Defina CODESIGN_IDENTITY="Developer ID Application: ..." para assinar de verdade.
set -euo pipefail
cd "$(dirname "$0")/.."
CONFIG=release
case "${1:-}" in
  --debug) CONFIG=debug;;
  "") ;;
  *) echo "arg desconhecido: $1" >&2; exit 2;;
esac
VERSION="$(tr -d '[:space:]' < VERSION)"
BUILD_NUMBER="${BUILD_NUMBER:-$(git rev-list --count HEAD 2>/dev/null || echo 0)}"
IDENTITY="${CODESIGN_IDENTITY:--}"

swift build -c "$CONFIG" --arch arm64
BIN_DIR="$(swift build -c "$CONFIG" --arch arm64 --show-bin-path)"

APP=build/WinTools.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_DIR/WinTools" "$APP/Contents/MacOS/WinTools"
cp Support/Info.plist "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$APP/Contents/Info.plist"

codesign --force --options runtime --timestamp=none --sign "$IDENTITY" "$APP"
codesign --verify --strict "$APP"
echo "bundle: $APP ($VERSION build $BUILD_NUMBER, $CONFIG, assinatura: $IDENTITY)"

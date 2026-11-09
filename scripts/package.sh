#!/usr/bin/env bash
# Gera os artefatos de release em dist/: WinTools-<versão>.zip e .dmg. Uso: scripts/package.sh
set -euo pipefail
cd "$(dirname "$0")/.."
VERSION="$(tr -d '[:space:]' < VERSION)"
./scripts/bundle.sh

mkdir -p dist
ZIP="dist/WinTools-$VERSION.zip"
DMG="dist/WinTools-$VERSION.dmg"
rm -f "$ZIP" "$DMG"
ditto -c -k --keepParent build/WinTools.app "$ZIP"

STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT
cp -R build/WinTools.app "$STAGING/"
ln -s /Applications "$STAGING/Applications"
hdiutil create -quiet -volname "WinTools $VERSION" -srcfolder "$STAGING" -format UDZO "$DMG"

(cd dist && shasum -a 256 "$(basename "$ZIP")" "$(basename "$DMG")" > "WinTools-$VERSION.sha256")
echo "package: $ZIP, $DMG"

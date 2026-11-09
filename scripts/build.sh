#!/usr/bin/env bash
# Compila o pacote Swift (arm64). Warnings quebram o build. Uso: scripts/build.sh [--release]
set -euo pipefail
cd "$(dirname "$0")/.."
CONFIG=debug
case "${1:-}" in
  --release) CONFIG=release;;
  "") ;;
  *) echo "arg desconhecido: $1" >&2; exit 2;;
esac
swift build -c "$CONFIG" --arch arm64 -Xswiftc -warnings-as-errors

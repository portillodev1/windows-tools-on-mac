#!/usr/bin/env bash
# Monta o app em debug e abre (ícone aparece na barra de menus). Uso: scripts/run.sh
set -euo pipefail
cd "$(dirname "$0")/.."
pkill -x WinTools 2>/dev/null || true
./scripts/bundle.sh --debug
open build/WinTools.app

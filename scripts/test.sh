#!/usr/bin/env bash
# Roda os testes (Swift Testing). Uso: scripts/test.sh [--filter <padrão>]
set -euo pipefail
cd "$(dirname "$0")/.."
FILTER=""
while [ $# -gt 0 ]; do case "$1" in
  --filter) FILTER="$2"; shift;;
  *) echo "arg desconhecido: $1" >&2; exit 2;;
esac; shift; done
swift test --arch arm64 ${FILTER:+--filter "$FILTER"}

#!/usr/bin/env bash
# Lint + format check com o swift-format do toolchain. Uso: scripts/lint.sh [--fix]
set -euo pipefail
cd "$(dirname "$0")/.."
PATHS=(Package.swift Sources Tests)
if [ "${1:-}" = "--fix" ]; then
  swift format format --in-place --recursive --parallel "${PATHS[@]}"
fi
swift format lint --strict --recursive --parallel "${PATHS[@]}"

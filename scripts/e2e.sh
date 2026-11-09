#!/usr/bin/env bash
# Testes ponta a ponta (XCUITest): gera o projeto Xcode a partir de project.yml e roda os testes de UI.
# ATENÇÃO: controla o mouse/teclado reais por alguns segundos. Na 1ª vez o macOS pede para
# autorizar a automação de UI (Touch ID/senha). Uso: scripts/e2e.sh [--filter <Classe/teste>]
set -euo pipefail
cd "$(dirname "$0")/.."
FILTER=""
while [ $# -gt 0 ]; do case "$1" in
  --filter) FILTER="$2"; shift;;
  *) echo "arg desconhecido: $1" >&2; exit 2;;
esac; shift; done

if ! command -v xcodegen >/dev/null; then
  echo "e2e: FAIL xcodegen não encontrado. Como corrigir: brew bundle (usa o Brewfile) ou brew install xcodegen" >&2
  exit 1
fi

OUT=build/xcode
RESULT="$OUT/e2e.xcresult"
mkdir -p "$OUT"
rm -rf "$RESULT"
pkill -x WinTools 2>/dev/null || true   # instância aberta pelo run.sh confundiria a barra de menus
# Gerado na raiz (gitignored): o XcodeGen não reescreve o caminho do pacote local em outra pasta.
xcodegen generate --quiet --spec project.yml

xcodebuild test \
  -project WinToolsE2E.xcodeproj \
  -scheme WinToolsUITests \
  -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath "$OUT/DerivedData" \
  -resultBundlePath "$RESULT" \
  ${FILTER:+-only-testing:"WinToolsUITests/$FILTER"} \
  -quiet \
  || { echo "e2e: FAIL — detalhes (com screenshots): open $RESULT" >&2; exit 1; }
echo "e2e: OK"

#!/usr/bin/env bash
# Sensor: roda os testes com cobertura e exige >= MIN% de linhas no WinToolsCore.
# Adaptadores de sistema (Sources/WinToolsCore/System/) ficam fora: são verificados manualmente.
# Uso: scripts/coverage.sh [--min <pct>]   (padrão 80)
set -euo pipefail
cd "$(dirname "$0")/.."
MIN=80
while [ $# -gt 0 ]; do case "$1" in
  --min) MIN="$2"; shift;;
  *) echo "arg desconhecido: $1" >&2; exit 2;;
esac; shift; done

swift test --arch arm64 --enable-code-coverage
JSON="$(swift test --arch arm64 --show-codecov-path)"

python3 -I - "$JSON" "$MIN" <<'PY'
import json, sys
path, minimum = sys.argv[1], float(sys.argv[2])
files = [f for f in json.load(open(path))["data"][0]["files"]
         if "/Sources/WinToolsCore/" in f["filename"] and "/Sources/WinToolsCore/System/" not in f["filename"]]
covered = sum(f["summary"]["lines"]["covered"] for f in files)
total = sum(f["summary"]["lines"]["count"] for f in files)
pct = 100.0 * covered / total if total else 100.0
for f in sorted(files, key=lambda f: f["summary"]["lines"]["percent"]):
    lines = f["summary"]["lines"]
    print(f"  {lines['percent']:5.1f}%  {f['filename'].split('/Sources/')[-1]}")
if pct < minimum:
    print(f"coverage: FAIL WinToolsCore {pct:.1f}% < {minimum:.0f}%.")
    print("  Como corrigir: adicione testes (rules/tests.md) para os arquivos com menor % acima.")
    print("  Efeito real de sistema? Coloque atrás de um protocolo e mova o adaptador para System/.")
    sys.exit(1)
print(f"coverage: OK WinToolsCore {pct:.1f}% (mínimo {minimum:.0f}%)")
PY

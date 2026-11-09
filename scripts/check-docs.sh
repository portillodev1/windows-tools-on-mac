#!/usr/bin/env bash
# Sensor: limite de linhas dos .md para agentes/humanos (progressive loading).
# Teto 100 linhas por arquivo. Uso: scripts/check-docs.sh
set -euo pipefail
cd "$(dirname "$0")/.."
MAX=100
FAIL=0
while IFS= read -r -d '' f; do
  n=$(wc -l < "$f" | tr -d ' ')
  if [ "$n" -gt "$MAX" ]; then
    echo "check-docs: FAIL $f tem $n linhas (teto $MAX)."
    echo "  Como corrigir: quebre em vários .md menores (30–70 linhas) e crie um índice com"
    echo "  uma quick reference table (quando ler cada um + link). Ver AGENTS.md → BOUNDARIES."
    FAIL=1
  fi
done < <(find . -name '*.md' -not -path './.build/*' -not -path './build/*' -not -path './dist/*' \
           -not -path './.git/*' -not -name 'LICENSE*' -print0)
[ "$FAIL" = 0 ] && echo "check-docs: OK (todos os .md ≤ $MAX linhas)"
exit "$FAIL"

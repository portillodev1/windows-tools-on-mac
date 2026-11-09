#!/usr/bin/env bash
# Gate final (eval gates 0/1): build + lint + arquitetura + docs + testes com cobertura.
# Saída 0 = pronto para concluir. Uso: scripts/verify.sh
set -euo pipefail
cd "$(dirname "$0")"
echo "== [1/5] build";        ./build.sh
echo "== [2/5] lint";         ./lint.sh
echo "== [3/5] architecture"; ./check-architecture.sh
echo "== [4/5] docs";         ./check-docs.sh
echo "== [5/5] tests+coverage"; ./coverage.sh
echo "verify: OK"

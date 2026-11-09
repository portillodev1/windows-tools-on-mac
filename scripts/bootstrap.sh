#!/usr/bin/env bash
# Bootstrap de sessão: reconstrói o contexto mínimo sem ler o repo inteiro (anti-amnésia).
# Uso: scripts/bootstrap.sh
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== Toolchain"
echo "macOS $(sw_vers -productVersion) · $(uname -m) · $(swift --version 2>/dev/null | head -1)"
[ "$(uname -m)" = "arm64" ] || echo "AVISO: o projeto só suporta Apple Silicon (arm64)."

echo; echo "== Git"
echo "branch: $(git branch --show-current) · versão: $(tr -d '[:space:]' < VERSION)"
git status --short | head -20
git log --oneline -5

echo; echo "== STATE.md → Handoff"
awk '/^## Handoff/{on=1; next} /^## /{on=0} on' STATE.md

echo; echo "== ROADMAP.md → Status"
awk '/^## Status/{on=1; next} /^## /{on=0} on' ROADMAP.md

echo; echo "Próximo passo: abra só a linha da Quick reference do AGENTS.md que casa com o pedido."

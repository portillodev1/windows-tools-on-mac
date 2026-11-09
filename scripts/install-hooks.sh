#!/usr/bin/env bash
# Ativa os git hooks versionados em .githooks/ (pre-commit: lint + arquitetura + docs).
# Uso: scripts/install-hooks.sh
set -euo pipefail
cd "$(dirname "$0")/.."
git config core.hooksPath .githooks
echo "hooks: core.hooksPath=.githooks"

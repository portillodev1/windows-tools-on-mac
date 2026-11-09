#!/usr/bin/env bash
# Sensor: regras de fronteira e de plataforma (ver rules/implementation.md e ADR-0002).
# Saída 0 = OK; 1 = violação, com o porquê e como corrigir. Uso: scripts/check-architecture.sh
set -euo pipefail
cd "$(dirname "$0")/.."
FAIL=0

# check <nome> <padrão regex> <caminhos...> -- <mensagem de correção>
violation() { # $1 = regra, $2 = achados, $3 = como corrigir
  echo "check-architecture: FAIL [$1]"
  echo "$2" | sed 's/^/  /'
  echo "  Como corrigir: $3"
  FAIL=1
}

hits=$(grep -rnE '^\s*import\s+SwiftUI' Sources/WinToolsCore || true)
[ -n "$hits" ] && violation "core-sem-swiftui" "$hits" \
  "WinToolsCore não importa SwiftUI. Mova a view para Sources/WinTools e exponha estado pelo FeatureManager."

hits=$(grep -rnE '\b(dlopen|dlsym|NSClassFromString|method_exchangeImplementations|class_replaceMethod|task_for_pid|mach_inject|DYLD_INSERT_LIBRARIES)\b' Sources || true)
[ -n "$hits" ] && violation "sem-injecao-ou-api-privada" "$hits" \
  "Injeção/swizzling/API privada são proibidos (ADR-0002). Use uma API pública documentada."

hits=$(grep -rnE '(\.terminate\(\)|\.forceTerminate\(\)|"killall"|/usr/bin/killall|pkill)' Sources \
        | grep -v 'Sources/WinToolsCore/System/AppRestarter.swift' | grep -v 'NSApplication.shared.terminate' || true)
[ -n "$hits" ] && violation "reinicio-so-via-AppRestarting" "$hits" \
  "Só o WorkspaceAppRestarter encerra apps. Declare o bundle id em FeatureDescriptor.affectedApps."

hits=$(grep -rnE 'DispatchQueue\.main\.(async|sync)' Sources || true)
[ -n "$hits" ] && violation "concorrencia-moderna" "$hits" \
  "Use async/await e @MainActor em vez de DispatchQueue.main (rules/implementation.md)."

hits=$(grep -rnoE 'id: "[^"]+"' Sources/WinToolsCore/FeatureCatalog.swift | grep -vE 'id: "[a-z0-9]+(-[a-z0-9]+)*"' || true)
[ -n "$hits" ] && violation "feature-id-kebab-case" "$hits" \
  "FeatureID é kebab-case minúsculo e estável (rules/features.md)."

for s in $(grep -oE 'scripts/[a-z-]+\.sh' AGENTS.md | sort -u); do
  [ -x "$s" ] || violation "agents-aponta-script-real" "$s citado no AGENTS.md" \
    "Crie o script (chmod +x) ou corrija a referência no AGENTS.md."
done

[ "$FAIL" = 0 ] && echo "check-architecture: OK"
exit "$FAIL"

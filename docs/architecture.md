# Arquitetura

## Módulos (SwiftPM)

| Target | Tipo | Responsabilidade |
|---|---|---|
| `WinToolsCore` | library | Catálogo, estado persistido, ativação de funcionalidades, reinício de apps |
| `WinTools` | executable | App de barra de menus (SwiftUI `MenuBarExtra`); só UI e composição |
| `WinToolsCoreTests` | tests | Swift Testing, com fakes para todo efeito de sistema |
| `WinToolsUITests` | XCUITest | Ponta a ponta do app real; só no projeto gerado por `project.yml` (ADR-0004) |

O `.app` não é gerado pelo Xcode: `scripts/bundle.sh` pega o binário do SwiftPM, junta com
`Support/Info.plist` (`LSUIElement` = sem ícone no Dock) e assina. Ver ADR-0001.

## Peças do Core

| Tipo | Papel |
|---|---|
| `FeatureDescriptor` | Metadados exibidos no menu (título, equivalente no Windows, apps afetados, permissões) |
| `Feature` | Protocolo com `apply()` / `revert()` |
| `FeatureCatalog` | Lista das funcionalidades conhecidas (hoje todas `.planned`) |
| `FeatureManager` | `@MainActor @Observable`; fonte de verdade da UI |
| `FeatureStateStore` | Persistência do que está ativo (`UserDefaults` em produção) |
| `AppRestarting` | Reinicia apps por bundle id (`System/AppRestarter.swift`, via `NSWorkspace`) |

Adaptadores reais de sistema ficam em `Sources/WinToolsCore/System/`: são finos, ficam fora
do gate de cobertura e são verificados manualmente com `scripts/run.sh`.

## Fluxo: usuário liga uma funcionalidade

```
Menu (Toggle) ──► FeatureManager.setEnabled(id, true)
                    1. valida: existe no catálogo, está .available, tem implementação
                    2. feature.apply()
                    3. restarter.restart(descriptor.affectedApps)
                    4. só então marca como ativa e persiste
```

Se o passo 2 ou 3 falhar, nada é persistido e a UI mostra o erro. Desligar segue o mesmo
caminho com `revert()`.

## Limites de plataforma

Finder e Terminal são apps da Apple protegidos pelo SIP: não dá para injetar código neles.
Toda funcionalidade usa APIs públicas (ver ADR-0002). Isso define o que é viável para cada
item do `ROADMAP.md`.

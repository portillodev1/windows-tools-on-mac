# HARNESS.md — Manifesto de Harness

> Manifesto vivo do harness deste repo. Atualize ao adicionar/alterar um controle ou aplicar
> steering. Inventário completo dos controles: [docs/harness-inventory.md](docs/harness-inventory.md).

## 1. Harnessability
- Swift 6 com strict concurrency: o compilador é um type checker e um detector de data race grátis.
- Fronteira clara: `WinToolsCore` (lógica, testável) ← `WinTools` (UI fina); efeitos de sistema
  atrás de protocolos, adaptadores reais em `Sources/WinToolsCore/System/`.
- Greenfield: sensores ligados desde o dia 1. Risco maior: efeitos reais de sistema (encerrar
  apps, pasteboard, permissões) que não dá para testar automaticamente → isolados e verificados
  manualmente.

## 2. Controles por categoria

### Manutenibilidade
| Controle | Direção | Execução | Onde roda | Sinal p/ LLM? |
|---|---|---|---|---|
| `AGENTS.md` + `rules/implementation.md` | guia | inferencial | antes da geração | — |
| Compilador Swift 6, `-warnings-as-errors` (`build.sh`) | sensor | computacional | pre-commit*/CI | sim (arquivo:linha) |
| `swift format lint --strict` (`lint.sh`) | sensor | computacional | pre-commit/CI | sim (arquivo:linha:regra) |
| `check-docs.sh` (todo `.md` ≤ 100 linhas) | sensor | computacional | pre-commit/CI | sim (com correção) |
| Code review (`/code-review` ou `sdd-final-reviewer`) | sensor | inferencial | antes do PR | — |

### Fitness de arquitetura
| Controle | Direção | Execução | Onde roda | Sinal p/ LLM? |
|---|---|---|---|---|
| ADR-0001..0003 + `rules/features.md` | guia | inferencial | antes da geração | — |
| `check-architecture.sh` (Core sem SwiftUI; sem injeção/API privada; reinício só via `AppRestarting`; sem `DispatchQueue.main`; `FeatureID` kebab-case; scripts do AGENTS existem) | sensor | computacional | pre-commit/CI | sim (regra + como corrigir) |
| `codesign --verify --strict` no `bundle.sh` | sensor | computacional | CI | sim |

### Comportamento
| Controle | Direção | Execução | Onde roda | Sinal p/ LLM? |
|---|---|---|---|---|
| Spec por funcionalidade (`.specs/<id>/`, `tlc-spec-driven`) | guia | inferencial | antes da geração | — |
| Swift Testing com fakes (`rules/tests.md`) | sensor | computacional | CI | sim |
| `coverage.sh` (≥ 80% linhas do Core, fora `System/`) | sensor | computacional | CI | sim (arquivos com menor %) |
| XCUITest do menu real (`scripts/e2e.sh`, ADR-0004) | sensor | computacional | antes do PR / CI | sim (asserção + screenshot no `.xcresult`) |
| Verificação manual (`scripts/run.sh`) do reinício real de apps | sensor | humano | antes do PR | — |

\* o pre-commit roda só os sensores baratos; o build fica no `verify.sh` e no CI.

## 3. Posicionamento no ciclo de vida ("keep quality left")
- **Pré-commit** (`.githooks/pre-commit`, ativar com `scripts/install-hooks.sh`): lint, arquitetura, docs.
- **Antes de "pronto"** (agente): `scripts/verify.sh` (os 5 gates).
- **Pipeline** (`ci.yml`): job `verify` (`verify.sh` + `bundle.sh`) e job `e2e` (`e2e.sh`) em macOS arm64.
- **Release** (`release.yml`): tag == `VERSION`, `verify.sh`, `package.sh`, publica artefatos.
- **Contínuo**: ainda não há (ver steering: dead code / drift quando o código crescer).

## 4. Loop de autocorreção — eval gates (0/1)
| Gate | Script | Falha diz |
|---|---|---|
| G1 build | `scripts/build.sh` | erro/warning do compilador com arquivo:linha |
| G2 lint | `scripts/lint.sh` | regra do swift-format violada (`--fix` corrige a maioria) |
| G3 arquitetura | `scripts/check-architecture.sh` | regra violada + como corrigir |
| G4 docs | `scripts/check-docs.sh` | arquivo acima do teto + como quebrar |
| G5 testes+cobertura | `scripts/coverage.sh` | teste falho, ou % por arquivo abaixo do mínimo |

| G6 e2e (fora do `verify.sh`) | `scripts/e2e.sh` | asserção de UI falha + caminho do `.xcresult` |

Agregado G1–G5: `scripts/verify.sh`. G6 controla mouse/teclado reais: rode antes de PR que mexe em UI/funcionalidade. O `loop-engineering` consome estes gates; o contrato
implementador × validador vive lá. O agente **não** se autoavalia: só `verify.sh` = 0 conta.

## 5. Memória e bootstrap
- `STATE.md`: decisões `AD-NNN`, perguntas em aberto e `## Handoff` (atualizar ao fim da sessão).
- `ROADMAP.md`: status por funcionalidade. Git: Conventional Commits, só com aprovação.
- `scripts/bootstrap.sh`: toolchain, git, Handoff e Status em uma tela — rode no início da sessão.

## 6. Steering log
| Data | Problema recorrente | Controle criado/ajustado |
|---|---|---|
| 2026-11-09 | (setup) Sensores provados com violações plantadas: todos disparam | baseline |
| 2026-11-09 | Faltava sensor de comportamento ponta a ponta do app real | G6 XCUITest (ADR-0004) |
